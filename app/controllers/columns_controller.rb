class ColumnsController < ApplicationController
  before_action :set_column, only: [:show, :edit, :update, :destroy, :approve]
  before_action :set_breadcrumbs
  before_action :set_noindex

def index
    # 1. 各ドメインが「どのジャンルを表示して良いか」を完全に定義
    # ここに記載がないものは、そのドメインでは絶対に表示されない
    config = case request.host
             when /ri-plus\.jp/
               { allowed: ["app"], default: "app" }
             when /自販機\.net/
               { allowed: ["vender"], default: "vender" }
             when /j-work\.jp/
               # j-workは複数ジャンルを許可
               { allowed: ["cargo", "cleaning", "logistics", "event", "housekeeping", "babysitter"], default: nil }
             when /^okey\.work$/
               { allowed: ["cleaning"], default: "cleaning" }
             when /column\.okey\.work/
               { allowed: nil, default: nil } # 全解放
             else
               { allowed: nil, default: nil }
             end

    @allowed_genres = config[:allowed]
    
    # 2. ベースクエリ（公開済みのみ）
    columns = Column.where.not(status: "draft").where.not(body: [nil, ""])

    # 3. ジャンルフィルタリング
    if @allowed_genres.present?
      # 現在のドメインで許可されていないジャンルをDBから除外
      columns = columns.where(genre: @allowed_genres)

      if params[:genre].present?
        # パラメータがある場合、それが許可リストに含まれているかチェック
        if @allowed_genres.include?(params[:genre])
          columns = columns.where(genre: params[:genre])
        else
          return render_404
        end
      elsif config[:default].present?
        # パラメータがなく、デフォルト設定があるドメイン（ri-plusなど）の場合
        columns = columns.where(genre: config[:default])
      end
    elsif params[:genre].present?
      # ハブサイト（制限なし）でパラメータがある場合
      columns = columns.where(genre: params[:genre])
    end

    # 4. 共通フィルタ
    columns = columns.where(status: params[:status]) if params[:status].present?
    columns = columns.where(article_type: params[:article_type]) if params[:article_type].present?
    
    @columns = columns.order(updated_at: :desc)
    
    # 子記事カウント
    column_ids = @columns.pluck(:id)
    @child_counts = column_ids.any? ? Column.where(parent_id: column_ids).where.not(body: [nil, ""]).group(:parent_id).count : {}
  end

  def show
    # 1. ドメインごとの閲覧権限チェック
    allowed_for_host = case request.host
                        when /ri-plus\.jp/ then ["app"]
                        when /自販機\.net/ then ["vender"]
                        when /j-work\.jp/ then ["cargo", "cleaning", "logistics", "event", "housekeeping", "babysitter"]
                        when /^okey\.work$/ then ["cleaning"]
                        when /column\.okey\.work/ then nil
                        else nil
                        end

    # 許可リストがあるドメインで、記事のジャンルが不一致なら404
    if allowed_for_host.present? && !allowed_for_host.include?(@column.genre)
      return render_404
    end

    # 2. 正規URL（301リダイレクト）
    # routes.rbの制約に合わせ、各ドメインでは必ず「:genre/columns/:id」の形にする
    if allowed_for_host.present?
      correct_path = columns_show_path(genre: @column.genre, id: @column.code)
      if request.path != correct_path
        return redirect_to correct_path, status: :moved_permanently
      end
    elsif request.host == "column.okey.work"
      # ハブサイトは /columns/:id
      correct_path = column_path(@column)
      if request.path != correct_path
        return redirect_to correct_path, status: :moved_permanently
      end
    end

    # 3. 表示用データ
    @children = @column.article_type == "pillar" ? @column.children.where.not(status: "draft").where.not(body: [nil, ""]).order(updated_at: :desc) : []

    markdown_body = @column.body.presence || "## 記事はまだ生成されていません。"
    raw_html_body = Kramdown::Document.new(markdown_body).to_html
    sanitized_html_body = raw_html_body.gsub(/<span[^>]*>|<\/span>/, '').gsub(/ style=\"[^\"]*\"/, '')

    @headings = []
    @column_body_with_ids = sanitized_html_body.gsub(/<(h[2-4])>(.*?)<\/\1>/m) do
      tag, text = Regexp.last_match(1), Regexp.last_match(2)
      idx = @headings.size
      @headings << { tag: tag, text: text, id: "heading-#{idx}", level: tag[1].to_i }
      "<#{tag} id='heading-#{idx}'>#{text}</#{tag}>"
    end
  end


  # --- 管理用 ---
  def new; @column = Column.new; end
  def create
    @column = Column.new(column_params)
    if @column.save; redirect_to columns_path, notice: "作成しました"; else; render 'new'; end
  end
  def edit; add_breadcrumb "記事編集", edit_column_path(@column); end
  def update
    if @column.update(column_params); redirect_to columns_path, notice: "更新しました"; else; render 'edit'; end
  end
  def destroy; @column.destroy; redirect_to columns_path, notice: "削除しました"; end

  def generate_gemini
    batch = params[:batch] || 20
    created = GeminiColumnGenerator.generate_columns(batch_count: batch.to_i)
    redirect_to draft_columns_path, notice: "#{created}件生成しました"
  end

  def draft
    @columns = Column.where(status: "draft").or(Column.where(body: [nil, ""])).order(created_at: :desc)
  end

  def approve
    unless @column.approved?
      @column.update!(status: "approved")
      GenerateColumnBodyJob.perform_later(@column.id)
    end
    redirect_to columns_path, notice: "承認しました。"
  end

  def bulk_update_drafts
    column_ids = params[:column_ids]
    return redirect_to draft_columns_path, alert: "対象未選択" if column_ids.blank?
    case params[:action_type]
    when "approve_bulk"
      Column.where(id: column_ids).each { |c| GenerateColumnBodyJob.perform_later(c.id) }
      redirect_to columns_path, notice: "生成開始"
    when "delete_bulk"
      count = Column.where(id: column_ids).destroy_all
      redirect_to draft_columns_path, notice: "#{count}件削除"
    end
  end

  def generate_pillar
    if params[:title].present?
      GptPillarGenerator.generate_full_article(params[:title], params[:genre], params[:choice])
      redirect_to draft_columns_path, notice: "ドラフト作成完了"
    else
      redirect_to new_column_path, alert: "タイトル未入力"
    end
  end

  def generate_from_selected
    ids = params[:column_ids]
    return redirect_to draft_columns_path, alert: "未選択" if ids.blank?
    Column.where(id: ids, article_type: "pillar").each { |c| GenerateColumnBodyJob.perform_later(c.id) }
    redirect_to draft_columns_path, notice: "生成開始"
  end

  def generate_from_pillar
    @column = Column.find_by(id: params[:id]) || Column.find_by!(code: params[:id])
    GenerateChildColumnsJob.perform_later(@column.id, 25)
    redirect_to column_path(@column), notice: "子記事生成開始"
  end

  private

  def set_column; @column = Column.friendly.find(params[:id]); end
  def set_noindex; @noindex = params[:genre].blank?; end
  def render_404; render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false; end

  def set_breadcrumbs
    add_breadcrumb 'トップ'
    genre_key = @column&.genre.present? ? @column.genre : params[:genre]
    if defined?(LpDefinition)
      label = LpDefinition.label(genre_key)
      add_breadcrumb label, "/#{genre_key}" if label
    end
    add_breadcrumb @column.title if action_name == 'show' && @column
  end

  def set_noindex
    @noindex = request.host == "column.okey.work"
  end

  def column_params
    params.require(:column).permit(
      :title, :file, :choice, :keyword, :description, :genre, :code, 
      :body, :status, :article_type, :parent_id, :cluster_limit, :prompt
    )
  end
end