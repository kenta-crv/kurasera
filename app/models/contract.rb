class Contract < ApplicationRecord
  CORPORATE_NAME_PATTERN = /(株式会社|合同会社|有限会社|合資会社|合名会社|一般社団法人|一般財団法人|NPO法人|医療法人|社会福祉法人|学校法人|宗教法人|特定非営利活動法人)/.freeze
  PREF_WAGES = {
    '北海道' => 1075, '青森県' => 1029, '岩手県' => 1031, '宮城県' => 1038, '秋田県' => 1031,
    '山形県' => 1032, '福島県' => 1033, '茨城県' => 1074, '栃木県' => 1068, '群馬県' => 1063,
    '埼玉県' => 1141, '千葉県' => 1140, '東京都' => 1226, '神奈川県' => 1225, '新潟県' => 1050,
    '富山県' => 1062, '石川県' => 1054, '福井県' => 1053, '山梨県' => 1052, '長野県' => 1061,
    '岐阜県' => 1065, '静岡県' => 1097, '愛知県' => 1140, '三重県' => 1087, '滋賀県' => 1080,
    '京都府' => 1122, '大阪府' => 1177, '兵庫県' => 1116, '奈良県' => 1051, '和歌山県' => 1045,
    '鳥取県' => 1030, '島根県' => 1033, '岡山県' => 1047, '広島県' => 1085, '山口県' => 1043,
    '徳島県' => 1046, '香川県' => 1036, '愛媛県' => 1033, '高知県' => 1023, '福岡県' => 1057,
    '佐賀県' => 1030, '長崎県' => 1031, '熊本県' => 1034, '大分県' => 1035, '宮崎県' => 1023,
    '鹿児島県' => 1026, '沖縄県' => 1023
  }.freeze
  PRICE_COMMON_ADD = 200

  attr_accessor :weekly_days, :daily_hours

  CJK_CHAR = /[\p{Han}\p{Hiragana}\p{Katakana}]/.freeze

  validates :company, presence: true, unless: -> { name.present? }
  validate :company_must_include_kaisha, if: -> { company.present? }

  before_validation :assign_service_from_inquiry

  def spam_inquiry?
    return false if origin.blank?

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
    extras = { 1 => 1200, 2 => 1100, 3 => 1100 }
    extra = extras[days] || 1000
    ((wage / 200.0).ceil * 200) + PRICE_COMMON_ADD + extra
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
    return true if digits.blank?
    return true if digits.start_with?('+') && !digits.start_with?('+81')

    national = digits.sub(/\A\+81/, '0')
    !national.match?(/\A0\d{9,10}\z/)
  end

  def address_without_japanese?
    !address.to_s.match?(CJK_CHAR)
  end

  def latin_gibberish_message?
    compact = message.to_s.gsub(/\s/, '')
    compact.match?(/\A[a-z]{16,}\z/)
  end
end
