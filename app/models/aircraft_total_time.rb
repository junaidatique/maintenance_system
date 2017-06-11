class AircraftTotalTime
  include Mongoid::Document


  field :carried_over_aircraft_hour, type: String
  field :carried_over_landings, type: String
  field :carried_over_uw_store, type: String
  field :this_sortie_aircraft_hour, type: String
  field :this_sortie_landings, type: String
  field :this_sortie_uw_store, type: String
  field :new_total_aircraft_hour, type: String
  field :new_total_landings, type: String
  field :new_total_uw_store, type: String
  field :correction_aircraft_hour, type: String
  field :correction_landings, type: String
  field :correction_uw_store, type: String
  field :corrected_total_aircraft_hour, type: String
  field :corrected_total_landings, type: String
  field :corrected_total_uw_store, type: String


  belongs_to :flying_log
end
