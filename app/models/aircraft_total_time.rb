class AircraftTotalTime
  include Mongoid::Document

  field :carried_over_landings, type: Integer, default: 0
  field :carried_over_aircraft_hours, type: Float, default: 0
  field :carried_over_engine_hours, type: Float, default: 0
  field :carried_over_prop_hours, type: Float, default: 0

  field :this_sortie_aircraft_hours, type: Float, default: 0
  field :this_sortie_landings, type: Integer, default: 0
  field :this_sortie_engine_hours, type: Float, default: 0
  field :this_sortie_prop_hours, type: Float, default: 0

  field :new_total_aircraft_hours, type: Float, default: 0
  field :new_total_landings, type: Integer, default: 0
  field :new_total_engine_hours, type: Float, default: 0
  field :new_total_prop_hours, type: Float, default: 0

  field :correction_aircraft_hours, type: Float, default: 0
  field :correction_landings, type: Integer, default: 0
  field :correction_engine_hours, type: Float, default: 0
  field :correction_prop_hours, type: Float, default: 0

  field :corrected_total_aircraft_hours, type: Float, default: 0
  field :corrected_total_landings, type: Integer, default: 0
  field :corrected_total_engine_hours, type: Float, default: 0
  field :corrected_total_prop_hours, type: Float, default: 0


  belongs_to :flying_log
end
