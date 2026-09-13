class ContractsController < ApplicationController
  #before_action :authenticate_admin!, only: [:index, :destroy, :send_mail]
    def index
      @contracts = Contract.order(created_at: "DESC").page(params[:page])
    end
  
    def new
      @contract = Contract.new
    end

    def create
  @contract = Contract.new(contract_params)

  origin_url = if @contract.origin.to_s.start_with?('/')
    @contract.origin
  else
    request.referer || root_path
  end

  via = params[:contact_via].to_s
  if via == 'line'
    @contract.message = ['依頼経路: LINE', @contract.message.presence].compact.join("\n")
  end

  if @contract.spam_inquiry?
    Rails.logger.warn("[spam] blocked contract create ip=#{request.remote_ip} origin=#{@contract.origin}")
    separator = origin_url.include?('?') ? '&' : '?'
    redirect_to "#{origin_url}#{separator}sent=1"
    return
  end

  if @contract.save
    ContractMailer.received_email(@contract).deliver_now
    ContractMailer.send_email(@contract).deliver_now if @contract.email.present?

    # LINE経由も完了画面を出してから友だち追加へ進む（home-care）
    if via == 'line' && !@contract.origin.to_s.start_with?('/home-care')
      redirect_to LpDefinition.line_consult_url, allow_other_host: true
      return
    end

    # 成功：元のページに「sent=1」を付けて戻す
    separator = origin_url.include?('?') ? '&' : '?'
    redirect_to "#{origin_url}#{separator}sent=1"
  else
    # 失敗：エラー内容をログに出力
    p @contract.errors.full_messages
    
    # 失敗：元のページに「error=1」を付けて戻す（renderは使わない）
    # renderを使うとURLが okey.work に変わってしまうため
    separator = origin_url.include?('?') ? '&' : '?'
    redirect_to "#{origin_url}#{separator}error=1"
  end
end

    def show
      @contract = Contract.find(params[:id])
      #@comment = Comment.new
    end
  
    def edit
      @contract = Contract.find(params[:id])
    end

    def destroy
      @contract = Contract.find(params[:id])
      @contract.destroy
      redirect_to contracts_path, alert:"削除しました"
    end
  
    def update
      @contract = Contract.find(params[:id])
    
      if @contract.update(contract_params)
        redirect_to root_path
      else
        # 更新が失敗した場合の処理
        render :edit
      end
    end

    private

    def contract_params
      params.require(:contract).permit(
      :company, #会社名
      :name, #担当者
      :tel, #電話番号
      :email, #メールアドレス
      :address, #所在地
      :url,
      :service,
      :weekly_days,
      :daily_hours,
      :period, #導入時期
      :message, #備考
      :origin,
      )
    end
end
