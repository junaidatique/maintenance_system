class FlightlineServicing
  include Mongoid::Document
  include SimpleEnum::Mongoid

  as_enum :inspection_performed, preflight: 0, thru_flight: 1
  field :flightline_time, type: String
  field :oil_refill, type: String

  belongs_to :user
  belongs_to :flying_log
end
