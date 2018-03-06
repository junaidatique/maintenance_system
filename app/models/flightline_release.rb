class FlightlineRelease
  include Mongoid::Document
  include Mongoid::Timestamps

  field :flight_time, type: String

  belongs_to :user
  belongs_to :flying_log
end
