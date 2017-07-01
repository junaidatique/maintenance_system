class AircraftTotalTime
  include Mongoid::Document


  field :carried_over_aircraft_hours, type: String
  field :carried_over_landings, type: String
  field :carried_over_engine_hours, type: String
  field :carried_over_prop_hours, type: String

  field :this_sortie_aircraft_hours, type: String
  field :this_sortie_landings, type: String
  field :this_sortie_engine_hours, type: String
  field :this_sortie_prop_hours, type: String

  field :new_total_aircraft_hours, type: String
  field :new_total_landings, type: String
  field :new_total_engine_hours, type: String
  field :new_total_prop_hours, type: String


  field :correction_aircraft_hours, type: String
  field :correction_landings, type: String
  field :correction_engine_hours, type: String
  field :correction_prop_hours, type: String

  field :corrected_total_aircraft_hours, type: String
  field :corrected_total_landings, type: String
  field :corrected_total_engine_hours, type: String
  field :corrected_total_prop_hours, type: String


  belongs_to :flying_log
end
