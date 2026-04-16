class Politician < ApplicationRecord
  has_many :activities, dependent: :destroy

  CHAMBERS = %w[衆院 参院].freeze
  PARTIES  = %w[自民党 立憲民主党 公明党 日本維新の会 国民民主党 共産党 れいわ新選組 無所属].freeze

  validates :name,      presence: true
  validates :name_kana, presence: true
  validates :party,     presence: true, inclusion: { in: PARTIES }
  validates :chamber,   presence: true, inclusion: { in: CHAMBERS }
end
