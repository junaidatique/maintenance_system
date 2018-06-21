class FlyingHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  field :this_aircraft_hours, type: Float, default: 0
  field :total_aircraft_hours, type: Float, default: 0
  field :touch_go, type: Integer, default: 0
  field :full_stop, type: Integer, default: 0
  field :total_landings, type: Integer, default: 0
  field :this_engine_hours, type: Float, default: 0
  field :total_engine_hours, type: Float, default: 0
  field :this_prop_hours, type: Float, default: 0
  field :total_prop_hours, type: Float, default: 0
  field :remarks, type: String

  belongs_to :aircraft
  belongs_to :flying_log, optional: true

end
