class Contract < ApplicationRecord
  CORPORATE_NAME_PATTERN = /(株式会社|合同会社|有限会社|合資会社|合名会社|一般社団法人|一般財団法人|NPO法人|医療法人|社会福祉法人|学校法人|宗教法人|特定非営利活動法人)/.freeze
  PREF_WAGES = {
    '北海道' => 1131, '青森県' => 1090, '岩手県' => 1090, '宮城県' => 1098, '秋田県' => 1090,
    '山形県' => 1092, '福島県' => 1094, '茨城県' => 1136, '栃木県' => 1125, '群馬県' => 1120,
    '埼玉県' => 1196, '千葉県' => 1195, '東京都' => 1280, '神奈川県' => 1279, '新潟県' => 1108,
    '富山県' => 1119, '石川県' => 1113, '福井県' => 1112, '山梨県' => 1113, '長野県' => 1117,
    '岐阜県' => 1121, '静岡県' => 1154, '愛知県' => 1195, '三重県' => 1143, '滋賀県' => 1136,
    '京都府' => 1180, '大阪府' => 1231, '兵庫県' => 1172, '奈良県' => 1107, '和歌山県' => 1101,
    '鳥取県' => 1090, '島根県' => 1092, '岡山県' => 1104, '広島県' => 1141, '山口県' => 1101,
    '徳島県' => 1103, '香川県' => 1092, '愛媛県' => 1093, '高知県' => 1086, '福岡県' => 1114,
    '佐賀県' => 1095, '長崎県' => 1087, '熊本県' => 1092, '大分県' => 1096, '宮崎県' => 1085,
    '鹿児島県' => 1090, '沖縄県' => 1086
  }.freeze
  PRICE_COMMON_ADD = 200

  attr_accessor :weekly_days, :daily_hours, :website

  CJK_CHAR = /[\p{Han}\p{Hiragana}\p{Katakana}]/.freeze

  validates :company, presence: true, unless: -> { name.present? }
  validate :company_must_include_kaisha, if: -> { company.present? }

  before_validation :assign_service_from_inquiry

  def spam_inquiry?
    return true if website.to_s.strip.present?

    name_without_japanese? ||
      foreign_or_invalid_tel? ||
      address_without_japanese? ||
      latin_gibberish_message?
  end

  def prefecture_from_address
    PREF_WAGES.keys.sort_by { |name| -name.length }.find { |name| address.to_s.include?(name) }
  end

  def inquiry_area_label
    prefecture_from_address || '全国（最安値）'
  end

  def weekly_days_count
    n = weekly_days.to_i
    return n if n.positive?
    return 7 if service.to_s.include?('毎日')

    service.to_s[/週(\d+)日/, 1].to_i
  end

  def daily_hours_count
    n = daily_hours.to_i
    return n if n.positive?

    service.to_s[/1日(\d+)時間/, 1].to_i
  end

  def inquiry_hourly_estimate
    days = weekly_days_count
    return if days.zero?

    wage = PREF_WAGES[prefecture_from_address] || PREF_WAGES.values.min
    extras = if origin.to_s.start_with?('/baby-care')
      { 1 => 1800, 2 => 1400, 3 => 1400 }
    else
      { 1 => 1200, 2 => 1100, 3 => 1100 }
    end
    extra = extras[days] || 1000
    ((wage / 50.0).ceil * 50) + PRICE_COMMON_ADD + extra
  end

  def inquiry_monthly_estimate
    hourly = inquiry_hourly_estimate
    hours = daily_hours_count
    days = weekly_days_count
    return unless hourly && hours.positive? && days.positive?

    hourly * hours * days * 4
  end

  private

  def assign_service_from_inquiry
    return if weekly_days.blank? && daily_hours.blank?

    day_label = weekly_days.to_i == 7 ? '毎日' : "週#{weekly_days}日"
    hour_label = daily_hours.present? ? "1日#{daily_hours}時間" : nil
    self.service = [day_label, hour_label].compact.join('・')
  end

  def company_must_include_kaisha
    unless company.match?(CORPORATE_NAME_PATTERN)
      errors.add(:company, 'には「株式会社」などの法人格を含める必要があります')
    end
  end

  def name_without_japanese?
    filled = [name, company].map { |v| v.to_s.strip }.reject(&:blank?).join
    filled.blank? || !filled.match?(CJK_CHAR)
  end

  def foreign_or_invalid_tel?
    digits = tel.to_s.gsub(/[^0-9+]/, '')
    return false if digits.blank?
    return true if digits.start_with?('+') && !digits.start_with?('+81')

    national = digits.sub(/\A\+81/, '0')
    !national.match?(/\A0\d{9,10}\z/)
  end

  def address_without_japanese?
    text = address.to_s.strip
    return false if text.blank?

    !text.match?(CJK_CHAR)
  end

  def latin_gibberish_message?
    compact = message.to_s.gsub(/\s/, '')
    compact.match?(/\A[a-z]{16,}\z/)
  end
end
