class AfterFlightServicing
  include Mongoid::Document

  field :flight_time, type: String
  field :oil_refill, type: String

  belongs_to :user
  belongs_to :flying_log
end
