class Fuel
  include Mongoid::Document

  field :fuel_remaining, type: String
  field :refill, type: String
  field :oil_remaining, type: String
  field :oil_serviced, type: String
  field :oil_total_qty, type: String

  belongs_to :flying_log

end
