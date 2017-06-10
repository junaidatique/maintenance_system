class Sortie
  include Mongoid::Document

  field :takeoff_time, type: Time
  field :landing_time, type: Time
  field :flight_time, type: String
  field :flight_minutes, type: String

  belongs_to :user
end
