class AircraftTotalTime
  include Mongoid::Document

  validates :carried_over_aircraft_hours, presence: true
  validates :carried_over_engine_hours, presence: true
  validates :carried_over_landings, presence: true
  validates :carried_over_prop_hours, presence: true

  validates :this_sortie_aircraft_hours, presence: true
  validates :this_sortie_engine_hours, presence: true
  validates :this_sortie_landings, presence: true
  validates :this_sortie_prop_hours, presence: true

  validates :new_total_aircraft_hours, presence: true
  validates :new_total_engine_hours, presence: true
  validates :new_total_landings, presence: true
  validates :new_total_prop_hours, presence: true

  validates :correction_aircraft_hours, presence: true
  validates :correction_engine_hours, presence: true
  validates :correction_landings, presence: true
  validates :correction_prop_hours, presence: true

  validates :corrected_total_aircraft_hours, presence: true
  validates :corrected_total_engine_hours, presence: true
  validates :corrected_total_landings, presence: true
  validates :corrected_total_prop_hours, presence: true

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
