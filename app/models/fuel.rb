class Fuel
  include Mongoid::Document

  validates :fuel_remaining, presence: true
  validates :refill, presence: true
  validates :oil_remaining, presence: true
  validates :oil_serviced, presence: true
  validates :oil_total_qty, presence: true

  field :fuel_remaining, type: String
  field :refill, type: String
  field :oil_remaining, type: String
  field :oil_serviced, type: String
  field :oil_total_qty, type: String

  belongs_to :flying_log

end
