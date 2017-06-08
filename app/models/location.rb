class Location
  include Mongoid::Document
  include Mongoid::Timestamps

  validates :name, presence: true

  field :name, type: String
  field :status, type: Mongoid::Boolean

  scope :active, -> { where(status: 1) }

  has_many :flying_logs
end
