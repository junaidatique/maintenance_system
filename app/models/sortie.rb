class Sortie
  include Mongoid::Document
  include SimpleEnum::Mongoid

  as_enum :sortie_code, C1: 1, C2: 2, C3: 3, C4: 4, C5: 5
  field :takeoff_time, type: String
  field :landing_time, type: String
  field :flight_time, type: String # tenth conversion table
  field :flight_minutes, type: String
  field :touch_go, type: String
  field :full_stop, type: String
  field :total_landings, type: String # to be calculated
  field :remarks, type: String
  field :third_seat_name, type: String

  validates :takeoff_time, presence: true
  validates :landing_time, presence: true
  validates :touch_go, presence: true
  validates :full_stop, presence: true
  validates :sortie_code, presence: true

  belongs_to :user, optional: true
  belongs_to :flying_log
  belongs_to :second_pilot, class_name: 'User', optional: true

  def calculate_flight_minutes
    takeoff_time = DateTime.strptime(self.takeoff_time, '%H:%M %p')
    landing_time = DateTime.strptime(self.landing_time, '%H:%M %p')
    ((landing_time - takeoff_time) * 24 * 60).to_i
  end

  def calculate_landings
    total_landings = touch_go.to_i + full_stop.to_i
  end

  def calculate_flight_time flight_minutes
    hours = flight_minutes.to_i / 60
    mins  = flight_minutes.to_i % 60
    mins_to_table = 0
    case mins
    when 3..8
      mins_to_table = 1
    when 9..14
      mins_to_table = 2
    when 15..20
      mins_to_table = 3
    when 21..26
      mins_to_table = 4
    when 27..33
      mins_to_table = 5
    when 34..39
      mins_to_table = 6
    when 40..45
      mins_to_table = 7
    when 46..51
      mins_to_table = 8
    when 52..57
      mins_to_table = 9
    when 58..59
      hours = hours.to_i + 1
    end
    "#{hours}.#{mins_to_table}"
  end

  def update_aircraft_times
    f_total = self.flying_log.aircraft_total_time
    f_total.this_sortie_aircraft_hours = (flight_minutes.to_f / 60).round(2)
    f_total.this_sortie_landings       = total_landings
    f_total.this_sortie_engine_hours   = (flight_minutes.to_f / 60).round(2)
    f_total.this_sortie_prop_hours     = (flight_minutes.to_f / 60).round(2)

    t_landings        = f_total.carried_over_landings.to_i + total_landings.to_i
    total_aircraft_hours  = f_total.carried_over_aircraft_hours.to_f + (flight_minutes.to_f / 60)
    total_engine_hours    = f_total.carried_over_engine_hours.to_f + (flight_minutes.to_f / 60)
    total_prop_hours      = f_total.carried_over_prop_hours.to_f + (flight_minutes.to_f / 60)

    f_total.new_total_landings        = t_landings
    f_total.new_total_aircraft_hours  = total_aircraft_hours.round(2)
    f_total.new_total_engine_hours    = total_engine_hours.round(2)
    f_total.new_total_prop_hours      = total_prop_hours.round(2)

    f_total.corrected_total_engine_hours     = total_engine_hours.round(2)
    f_total.corrected_total_aircraft_hours   = total_aircraft_hours.round(2)
    f_total.corrected_total_landings         = t_landings
    f_total.corrected_total_prop_hours       = total_prop_hours.round(2)

    self.flying_log.aircraft.update_part_values flying_log

  end
end
