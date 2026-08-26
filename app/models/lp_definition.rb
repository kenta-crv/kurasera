# app/models/lp_definition.rb
module LpDefinition
  MAP = {
    'baby'         => 'ベビーシッター',
    'babysitter'   => '外国人ベビーシッター',
    'housekeeping' => '家事代行',
    'living'       => '暮らしサポート'
  }.freeze

  def self.label(key)
    MAP[key]
  end
end
