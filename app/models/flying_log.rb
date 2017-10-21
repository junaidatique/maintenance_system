class FlyingLog
  require 'autoinc'

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Autoinc


  # validates :fuel_refill, presence: true, if: :is_flightline_serviced?
  # validates :oil_serviced, presence: true, if: :is_flightline_serviced?

  field :number, type: Integer
  field :log_date, type: Date

  field :fuel_remaining, type: String
  field :fuel_refill, type: String
  field :oil_remaining, type: String
  field :oil_serviced, type: String
  field :oil_total_qty, type: String


  # def is_flightline_serviced?
  #   puts state == "flightline_serviced"
  #   state == "flightline_serviced"
  # end

  state_machine initial: :started do
    audit_trail initial: false,  context: [:aircraft, :location]
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

  increments :number, seed: 1000

  belongs_to :aircraft
  belongs_to :location

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
      Techlog.create({type_cd: 0, log_time: "#{Time.zone.now.strftime("%H:%M %p")}", 
        description: f.flightline_servicing.inspection_performed, work_unit_code: work.id, 
        user_id: f.flightline_servicing.user_id, log_date: "#{Time.zone.now.strftime("%Y-%m-%d")}", 
        aircraft_id: f.aircraft_id, flying_log_id: f.id, location_id: f.location_id})
    end
  end

end
