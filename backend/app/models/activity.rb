class Activity < ApplicationRecord
  belongs_to :politician

  ACTIVITY_TYPES = %w[speech sns committee vote other].freeze

  validates :activity_type, presence: true, inclusion: { in: ACTIVITY_TYPES }
  validates :description,   presence: true
  validates :occurred_at,   presence: true

  scope :recent,   -> { order(occurred_at: :desc) }
  scope :by_type,  ->(type) { where(activity_type: type) }
end
