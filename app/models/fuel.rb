class Fuel
  include Mongoid::Document

  field :fuel_remaining, type: String
  field :refill, type: String
  field :total_uwt, type: String
  field :total_main, type: String
  field :fob_total, type: String

  belongs_to :flying_log

end
