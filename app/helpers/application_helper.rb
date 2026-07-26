module ApplicationHelper
  def default_meta_tags
    {
      site: "暮らしのサポートなら『J Work』｜ベビーシッター・家事代行",
      description: "ベビーシッター・外国人シッター・家事代行まで。暮らしを支えるサービスなら『J Work』（kurasera.life）にお任せください。",
      canonical: request.original_url,
      charset: "UTF-8",
      reverse: true,
      separator: '|',
      icon: [
        { href: image_url('favicon.ico') },
        { href: image_url('favicon.ico'), rel: 'apple-touch-icon' },
      ],
    }
  end

  def breadcrumb_list_json_ld
    return if !defined?(breadcrumbs) || breadcrumbs.blank?

    items = breadcrumbs.each_with_index.map do |crumb, i|
      item = {
        "@type" => "ListItem",
        "position" => i + 1,
        "name" => crumb[:label]
      }
      item["item"] = crumb[:path].present? ? "#{request.base_url}#{crumb[:path]}" : request.original_url
      item
    end

    {
      "@context" => "https://schema.org",
      "@type" => "BreadcrumbList",
      "itemListElement" => items
    }.to_json
  end

  def organization_json_ld
    {
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "name" => "クラセラ",
      "legalName" => "株式会社J Work",
      "url" => "https://kurasera.life/",
      "logo" => "https://kurasera.life#{image_path('favicon.ico')}",
      "description" => "ベビーシッター・家事代行など、暮らしのサポートならクラセラ。",
      "address" => {
        "@type" => "PostalAddress",
        "streetAddress" => "芝5-27-3 MBC・Aー9",
        "addressLocality" => "港区",
        "addressRegion" => "東京都",
        "addressCountry" => "JP"
      }
    }.to_json
  end

  def website_json_ld
    {
      "@context" => "https://schema.org",
      "@type" => "WebSite",
      "name" => "クラセラ",
      "url" => "https://kurasera.life/",
      "inLanguage" => "ja",
      "publisher" => {
        "@type" => "Organization",
        "name" => "株式会社J Work"
      }
    }.to_json
  end

  def faq_page_json_ld(items)
    entities = Array(items).filter_map do |item|
      q = (item.is_a?(Array) ? item[0] : (item[:q] || item["q"])).to_s.strip
      a = (item.is_a?(Array) ? item[1] : (item[:a] || item["a"])).to_s.strip
      next if q.blank? || a.blank?

      {
        "@type" => "Question",
        "name" => q,
        "acceptedAnswer" => {
          "@type" => "Answer",
          "text" => a
        }
      }
    end
    return if entities.blank?

    {
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" => entities
    }.to_json
  end

  def lp_faqs_for_current_page
    case action_name
    when "housekeeping"
      [
        { q: "どのようなスタッフが来ますか？", a: "当社の厳しい選考をクリアし、身元保証が確認された清潔感のあるプロスタッフが伺います。清掃や主婦経験豊富なベテランも多数在籍しています。" },
        { q: "不在時でもお願いできますか？", a: "はい、鍵をお預かりしての不在時サービスも可能です。その際は当社の鍵預かり規定に基づき、厳重に管理・運用いたします。" },
        { q: "損害保険には加入していますか？", a: "はい。万が一の破損や事故に備え、賠償責任保険に加入しております。誠心誠意対応いたしますのでご安心ください。" },
        { q: "急なキャンセルは可能ですか？", a: "前日の所定の時間までにご連絡いただければ無料で変更・キャンセルが可能です。詳細は契約時の規約をご確認ください。" },
        { q: "お掃除道具はこちらで用意しますか？", a: "基本的にお客様のご自宅にある道具・洗剤をお借りして作業いたします。普段使い慣れた道具で、お好みの仕上がりを実現します。" },
        { q: "料理もお願いできますか？", a: "可能です。作り置きや夕食の準備など、ご要望に合わせて料理経験のあるスタッフを調整いたします。" },
        { q: "プライバシーは守られますか？", a: "もちろんです。スタッフには徹底した機密保持教育を行っております。お客様の個人情報やご家庭内の情報が外に漏れることはございません。" }
      ]
    when "baby"
      [
        { q: "シッターさんに預けるのが初めてですが、大丈夫でしょうか？", a: "全く問題ありません！お子様がリラックスして過ごせるよう、丁寧にお子様のペースに合わせます。事前に面談やご要望のヒアリングも可能ですのでご安心ください。" },
        { q: "どんなシッターさんが在籍していますか？", a: "当社のスタッフは保育経験豊富なプロフェッショナルです。20代から50代まで、お子様の年齢や性格に合わせたマッチングが可能な人材が在籍しております。" },
        { q: "学校や習い事の宿題も見てもらえますか？", a: "はい、可能です。学校の宿題チェックや読み書きの指導、また日々の学習習慣を身につけるためのサポートなども柔軟に対応いたします。" },
        { q: "当日の急な依頼でも大丈夫ですか？", a: "スタッフの空き状況によりますが、可能な限り調整いたします。まずはお電話またはお問合せフォームよりご連絡ください。" },
        { q: "お食事の準備はお願いできますか？", a: "お客様のご要望に応じて、家事代行・ベビーシッターと併用して承ります。お子様向けの簡単なお料理や温め直しなどもお任せください。" },
        { q: "万が一の時の保険などはありますか？", a: "はい、当社では対人・対物賠償責任保険に加入しております。お子様の安全を最優先に考え、万全の体制でサポートさせていただきます。" }
      ]
    when "babysitter"
      [
        { q: "英語が全く話せませんが、預けても大丈夫でしょうか？", a: "全く問題ありません！お子様はジェスチャーや表情から意図を汲み取る天才です。スタッフも日本語が堪能なので、お子さんの性格に合わせながら対応が可能です。" },
        { q: "スタッフの方はどんな国籍の方がいますか？", a: "当社のスタッフは多国籍に富んでおりますので、ヨーロッパ系・アフリカ系・アメリカ系・アジア系と様々なスタッフが在籍しております。" },
        { q: "インターナショナルスクールの宿題も見てもらえますか？", a: "はい、可能です。英語での宿題チェックや読み書きの指導、またインター校での生活に必要なコミュニケーションの練習などもサポートいたします。" },
        { q: "当日の急な依頼でも大丈夫ですか？", a: "スタッフの空き状況によりますが、可能な限り調整いたします。まずはお電話またはお問合せフォームよりご連絡ください。" },
        { q: "お食事の準備はお願いできますか？", a: "お客様のご要望に応じて、家事代行・ベビーシッターと併用してこなさせて頂きますので、お料理もお任せください。" },
        { q: "日本語でのコミュニケーションは取れますか？", a: "当社のスタッフは日本での在住が10〜30年ほどの永住ビザスタッフとなります。日本語コミュニケーションは全く問題ございません。" }
      ]
    else
      []
    end
  end
end
