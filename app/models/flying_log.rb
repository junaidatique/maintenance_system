class FlyingLog
  require 'autoinc'

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Autoinc

  field :number, type: Integer
  field :serial_no, type: String
  field :log_date, type: Date
  field :fuel_remaining, type: Float
  field :fuel_refill, type: Float
  field :fuel_total, type: Float
  
  field :oil_remaining, type: Float
  field :oil_serviced, type: Float
  field :oil_total_qty, type: Float
  
  field :location_from, type: String
  field :location_to, type: String
  field :completion_time, type: String
  
  # validates :location_from, presence: true
  # validates :location_to, presence: true  
  validate :check_techlogs
  validate :check_parts

  def check_parts
    if aircraft.parts.engine_part.count == 0
      errors.add(:aircraft_id, " has no engine.")
    end
    if aircraft.parts.propeller_part.count == 0
      errors.add(:aircraft_id, " has no propeller.")
    end
  end

  def check_techlogs    
    if flight_released?
      if aircraft.techlogs.incomplete.count > 0
        errors.add(:aircraft_id, " has some pending techlogs")
      end
    end
  end

  scope :completed, -> { where(state: :log_completed) }
  scope :not_completed, -> { ne(state: :log_completed) }
  default_scope { order(id: :desc) }
  
  increments :number, seed: 1000

  state_machine initial: :started do
    #audit_trail initial: false,  context: [:aircraft]

    after_transition on: :complete_log, do: :update_aircraft_timgings
    after_transition on: :pilot_back, do: :update_aircraft_times
    after_transition on: :complete_log, do: :update_aircraft_times

    event :flightline_service do
      transition started: :flightline_serviced
    end
    event :fill_fuel do
      transition flightline_serviced: :fuel_filled
    end
    event :complete_servicing do
      transition fuel_filled: :servicing_completed
    end
    event :release_flight do
      transition servicing_completed: :flight_released
    end
    event :book_flight do
      transition flight_released: :flight_booked
    end
    event :pilot_back do
      transition flight_booked: :pilot_commented
    end
    event :techlog_check do
      transition pilot_commented: :logs_created
    end
    event :complete_log do
      transition logs_created: :log_completed
    end
  end

  


  belongs_to :aircraft
  
  has_one :ac_configuration, dependent: :destroy
  has_one :capt_acceptance_certificate, dependent: :destroy
  has_one :sortie, dependent: :destroy
  has_one :capt_after_flight, dependent: :destroy
  has_one :flightline_release, dependent: :destroy
  has_one :aircraft_total_time, dependent: :destroy
  has_one :after_flight_servicing, dependent: :destroy
  has_one :flightline_servicing, dependent: :destroy
  has_one :post_mission_report, dependent: :destroy
  has_one :flying_history, dependent: :destroy
  has_many :techlogs, dependent: :destroy

  # embeds_many :notifications, as: :notifiable
  embeds_many :flying_log_state_transitions

  accepts_nested_attributes_for :ac_configuration
  accepts_nested_attributes_for :capt_acceptance_certificate
  accepts_nested_attributes_for :sortie
  accepts_nested_attributes_for :capt_after_flight
  accepts_nested_attributes_for :flightline_release
  accepts_nested_attributes_for :aircraft_total_time
  accepts_nested_attributes_for :after_flight_servicing
  accepts_nested_attributes_for :flightline_servicing
  accepts_nested_attributes_for :post_mission_report
  accepts_nested_attributes_for :techlogs, reject_if: :all_blank, allow_destroy: true

  after_create :create_serial_no
  after_create :create_techlogs
  before_create :update_times

  def create_serial_no
    self.serial_no = "#{Time.zone.now.strftime('%d%m%Y')}-#{aircraft.tail_number}-#{flightline_servicing.inspection_performed.to_s.downcase}-#{number}"
    self.save
  end

  def create_techlogs
    if self.flightline_servicing.inspection_performed_cd == 0
      wucs = WorkUnitCode.preflight
    elsif self.flightline_servicing.inspection_performed_cd == 1
      wucs = WorkUnitCode.thru_flight
    elsif self.flightline_servicing.inspection_performed_cd == 2
      wucs = WorkUnitCode.post_flight
    end
    f = self
    wucs.each do |work|
      Techlog.create({type_cd: 0, condition_cd: 0, log_time: "#{Time.zone.now.strftime("%H:%M %p")}", 
        description: f.flightline_servicing.inspection_performed, work_unit_code: work.id, 
        user_id: f.flightline_servicing.user_id, log_date: "#{Time.zone.now.strftime("%Y-%m-%d")}", 
        aircraft_id: f.aircraft_id, flying_log_id: f.id, dms_version: System.first.settings['dms_version_number'] })
    end
  end

  def update_times
    build_aircraft_total_time
    aircraft_total_time.carried_over_engine_hours     = aircraft.parts.engine_part.first.completed_hours
    aircraft_total_time.carried_over_aircraft_hours   = aircraft.flight_hours
    aircraft_total_time.carried_over_landings         = aircraft.landings
    aircraft_total_time.carried_over_prop_hours       = aircraft.parts.propeller_part.first.completed_hours
    aircraft_total_time.corrected_total_engine_hours     = aircraft.parts.engine_part.first.completed_hours
    aircraft_total_time.corrected_total_aircraft_hours   = aircraft.flight_hours
    aircraft_total_time.corrected_total_landings         = aircraft.landings
    aircraft_total_time.corrected_total_prop_hours       = aircraft.parts.propeller_part.first.completed_hours
  end

  def update_fuel
    self.fuel_remaining  = aircraft.fuel_capacity.to_f - fuel_refill.to_f
    self.oil_remaining   = aircraft.oil_capacity.to_f - oil_serviced.to_f
    self.oil_total_qty   = aircraft.oil_capacity
    self.fuel_total      = aircraft.fuel_capacity
  end

  def update_aircraft_timgings    
    self.completion_time = Time.zone.now
    self.save
    # self.aircraft.update_part_values self
  end

  def update_aircraft_times
    sortie = self.sortie
    sortie.total_landings = sortie.touch_go.to_i + sortie.full_stop.to_i
    sortie.flight_minutes = sortie.calculate_flight_minutes
    sortie.flight_time    = sortie.calculate_flight_time
    sortie.total_landings = sortie.calculate_landings

    f_total = self.aircraft_total_time
    f_total.this_sortie_aircraft_hours = sortie.flight_time.to_f.round(2)
    f_total.this_sortie_landings       = sortie.total_landings
    f_total.this_sortie_engine_hours   = sortie.flight_time.to_f.round(2)
    f_total.this_sortie_prop_hours     = sortie.flight_time.to_f.round(2)

    t_landings            = f_total.carried_over_landings.to_i + sortie.total_landings.to_i
    total_aircraft_hours  = f_total.carried_over_aircraft_hours.to_f + sortie.flight_time.to_f.round(2)
    total_engine_hours    = f_total.carried_over_engine_hours.to_f + sortie.flight_time.to_f.round(2)
    total_prop_hours      = f_total.carried_over_prop_hours.to_f + sortie.flight_time.to_f.round(2)

    f_total.new_total_landings        = t_landings
    f_total.new_total_aircraft_hours  = total_aircraft_hours.round(2)
    f_total.new_total_engine_hours    = total_engine_hours.round(2)
    f_total.new_total_prop_hours      = total_prop_hours.round(2)

    f_total.corrected_total_engine_hours     = total_engine_hours.round(2)
    f_total.corrected_total_aircraft_hours   = total_aircraft_hours.round(2)
    f_total.corrected_total_landings         = t_landings
    f_total.corrected_total_prop_hours       = total_prop_hours.round(2)

    self.aircraft.update_part_values self
    self.create_history
  end

  def create_history
    history = FlyingHistory.where(flying_log_id: self.id).first
    history = FlyingHistory.new if history.blank?
    history.aircraft        = aircraft
    history.this_aircraft_hours   = aircraft_total_time.this_sortie_aircraft_hours
    history.total_aircraft_hours  = aircraft_total_time.corrected_total_aircraft_hours

    history.this_engine_hours     = aircraft_total_time.this_sortie_engine_hours
    history.total_engine_hours    = aircraft_total_time.corrected_total_engine_hours

    history.this_prop_hours       = aircraft_total_time.this_sortie_prop_hours
    history.total_prop_hours      = aircraft_total_time.corrected_total_prop_hours

    history.total_landings  = aircraft_total_time.corrected_total_landings    
    history.touch_go        = sortie.touch_go
    history.full_stop       = sortie.full_stop
    history.flying_log      = self
    history.save!
  end

end
