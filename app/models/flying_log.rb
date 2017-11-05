class FlyingLog
  require 'autoinc'

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Autoinc

  field :number, type: Integer
  field :log_date, type: Date
  field :fuel_remaining, type: Float
  field :fuel_refill, type: Float
  field :oil_remaining, type: Float
  field :oil_serviced, type: Float
  field :oil_total_qty, type: Float
  field :location_from, type: String
  field :location_to, type: String
  
  validates :location_from, presence: true
  validates :location_to, presence: true  

  increments :number, seed: 1000

  state_machine initial: :started do
    audit_trail initial: false,  context: [:aircraft]
    event :flightline_service do
      transition started: :flightline_serviced
    end
    event :fill_fuel do
      transition flightline_serviced: :fuel_filled
    end
    event :flight_release do
      transition fuel_filled: :flight_released
    end
    event :book_flight do
      transition flight_released: :flight_booked
    end
    event :pilot_back do
      transition flight_booked: :pilot_commented
    end
    event :complete_log do
      transition pilot_commented: :log_completed
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
  accepts_nested_attributes_for :techlogs

  after_create :create_techlogs
  before_create :update_times

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
        aircraft_id: f.aircraft_id, flying_log_id: f.id})
    end
  end

  def update_times
    build_aircraft_total_time
    aircraft_total_time.carried_over_engine_hours     = aircraft.engine_hours
    aircraft_total_time.carried_over_aircraft_hours   = aircraft.flight_hours
    aircraft_total_time.carried_over_landings         = aircraft.landings
    aircraft_total_time.carried_over_prop_hours       = aircraft.prop_hours
    aircraft_total_time.corrected_total_engine_hours     = aircraft.engine_hours
    aircraft_total_time.corrected_total_aircraft_hours   = aircraft.flight_hours
    aircraft_total_time.corrected_total_landings         = aircraft.landings
    aircraft_total_time.corrected_total_prop_hours       = aircraft.prop_hours
  end

  def update_fuel
    self.fuel_remaining  = aircraft.fuel_capacity.to_f - fuel_refill.to_f
    self.oil_remaining   = aircraft.oil_capacity.to_f - oil_serviced.to_f
    self.oil_total_qty   = aircraft.oil_capacity
  end

end
