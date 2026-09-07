# app/models/lp_definition.rb
module LpDefinition
  MAP = {
    'baby'         => 'ベビーシッター',
    'babysitter'   => '外国人ベビーシッター',
    'housekeeping' => '家事代行',
    'living'       => '暮らしサポート',
    'home_care'    => '家事代行'
  }.freeze

  LINE_CONSULT_URL = ENV['KURASERA_LINE_URL'].presence || 'https://lin.ee/9ZFcQXSw'
  LINE_OA_ID = ENV['KURASERA_LINE_OA_ID'].presence

  def self.label(key)
    MAP[key]
  end

  def self.line_consult_url
    LINE_CONSULT_URL
  end

  def self.line_oa_id
    LINE_OA_ID
  end
end
