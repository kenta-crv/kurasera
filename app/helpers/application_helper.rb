module ApplicationHelper
  def default_meta_tags
    {
      site: "暮らしのサポートなら『クラセラ』｜ベビーシッター・家事代行",
      description: "ベビーシッター・外国人シッター・家事代行まで。暮らしを支えるサービスなら『クラセラ』（kurasera.life）にお任せください。",
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
        "streetAddress" => "浜松町２丁目２番１５号２Ｆ",
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
    when "home_care"
      [
        { category: "service", q: "どのようなスタッフが来ますか？", a: "家事経験のあるスタッフが伺います。" },
        { category: "service", q: "不在時でもお願いできますか？", a: "はい。鍵をお預かりしての不在時サービスも可能です。鍵は当社の預かり規定に沿って管理します。" },
        { category: "service", q: "お掃除道具はこちらで用意しますか？", a: "基本的にご自宅の道具・洗剤をお借りして作業します。" },
        { category: "service", q: "料理もお願いできますか？", a: "可能です。作り置きや夕食の準備など、ご要望に合わせて料理経験のあるスタッフを調整します。" },
        { category: "service", q: "プライバシーは守られますか？", a: "ご家庭の情報は外部に出しません。" },
        { category: "pricing", q: "料金の目安はいくらですか？", a: "全国の最安プランの目安は2,400円〜／時間です。都道府県とプランで変わります。料金表で都道府県を選ぶと目安が出ます。" },
        { category: "pricing", q: "1回だけお願いできますか？", a: "定期でのご利用です。週1回から始められます。" },
        { category: "pricing", q: "何時間から頼めますか？", a: "2時間からです。" },
        { category: "pricing", q: "交通費はかかりますか？", a: "交通費は実費です。" },
        { category: "setup", q: "申し込みから利用開始までの流れは？", a: "お問い合わせのあと、金額と範囲に納得いただいてから対応できるスタッフを選定し、ご自宅へ伺います。" },
        { category: "setup", q: "お見積りは無料ですか？", a: "はい。お見積りは無料です。" },
        { category: "setup", q: "週何回から利用できますか？", a: "週1回から利用できます。" },
        { category: "usage", q: "対応エリアはどこですか？", a: "日本全国です。" },
        { category: "usage", q: "希望の曜日や時間に来てもらえますか？", a: "ご希望の曜日・時間に合わせて伺います。" },
        { category: "usage", q: "急なキャンセルは可能ですか？", a: "前日の所定の時間までにご連絡いただければ、変更・キャンセルは無料です。詳細は契約時の規約をご確認ください。" }
      ]
    else
      []
    end
  end

  def home_care_faq_categories
    [
      ["service", "サービスについて", "mail"],
      ["pricing", "料金", "calc"],
      ["setup", "申し込み・開始", "calendar"],
      ["usage", "ご利用について", "clock"]
    ]
  end
end
