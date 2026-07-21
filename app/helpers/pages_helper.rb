module PagesHelper
  FEATURED_COLUMNS = {
    top: [
      { title: "家事代行を利用して得られる生活の質の向上", path: "/columns/improving-quality-of-life-with-housekeeping-services" },
      { title: "共働き家庭が家事代行を選ぶ理由とその影響", path: "/columns/working-family-housekeeping-c55dbff7-650e-406e-80df-8dfcbfc2f910" },
      { title: "家事代行サービスが共働き家庭の子育てに与える影響", path: "/columns/impact-of-housekeeping-services-on-working-parents" },
      { title: "家事代行を利用した共働き家庭の時間管理術", path: "/columns/time-management-for-working-families-using-housekeeping-services" },
      { title: "家事代行がもたらす共働き家庭のストレス軽減効果", path: "/columns/stress-relief-for-working-families" }
    ],
    baby: [
      { title: "家事代行サービスが共働き家庭の子育てに与える影響", path: "/columns/impact-of-housekeeping-services-on-working-parents" },
      { title: "家事代行を利用した共働き家庭の時間管理術", path: "/columns/time-management-for-working-families-using-housekeeping-services" },
      { title: "家事代行がもたらす共働き家庭のストレス軽減効果", path: "/columns/stress-relief-for-working-families" },
      { title: "共働き家庭が家事代行を選ぶ理由とその影響", path: "/columns/working-family-housekeeping-c55dbff7-650e-406e-80df-8dfcbfc2f910" },
      { title: "家事代行を通じて得られる共働き家庭の新たなライフスタイル", path: "/columns/new-lifestyle-through-housekeeping-services" }
    ],
    babysitter: [
      { title: "家事代行サービスが共働き家庭の子育てに与える影響", path: "/columns/impact-of-housekeeping-services-on-working-parents" },
      { title: "家事代行を利用した共働き家庭の時間管理術", path: "/columns/time-management-for-working-families-using-housekeeping-services" },
      { title: "共働き家庭が家事代行を使う際の注意点", path: "/columns/caution-tips-for-housekeeping-services" },
      { title: "家事代行利用後の共働き家庭の生活の質向上", path: "/columns/improvement-of-quality-of-life-in-working-couples-after-using-housekeeping-services" },
      { title: "家事代行サービスが共働き家庭に与える時間の価値", path: "/columns/value-of-housekeeping-services-for-working-families" }
    ],
    housekeeping: [
      { title: "家事代行とロボット掃除機、結局どちらがコスパ最強なのか", path: "/columns/housekeeping-vs-robot-vacuum-cost-performance" },
      { title: "家事代行の依頼時に確認すべきポイント", path: "/columns/points-to-check-when-ordering-housekeeping-services" },
      { title: "共働き世帯のための家事代行サービスの選び方", path: "/columns/how-to-choose-housekeeping-services-for-working-couples" },
      { title: "共働き家庭向け家事代行サービスの料金相場", path: "/columns/housekeeping-services-pricing" },
      { title: "家事代行の利用に関するよくある誤解と真実", path: "/columns/misconceptions-about-housekeeping-services" }
    ]
  }.freeze

  def featured_columns_for(page_key)
    FEATURED_COLUMNS[page_key.to_sym] || FEATURED_COLUMNS[:top]
  end
end
