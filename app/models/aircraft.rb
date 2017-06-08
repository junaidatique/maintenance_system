class Aircraft
  include Mongoid::Document
  include Mongoid::Timestamps

  validates :number, :name, presence: true

  field :number, type: String
  field :name, type: String
  field :status, type: Mongoid::Boolean

  scope :active, -> { where(status: 1) }

  has_many :flying_logs
end