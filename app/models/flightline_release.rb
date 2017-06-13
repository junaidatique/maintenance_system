class FlightlineRelease
  include Mongoid::Document

  field :flight_time, type: String

  belongs_to :user
  belongs_to :flying_log
end
