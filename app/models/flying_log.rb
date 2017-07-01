class FlyingLog
  require 'autoinc'

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Autoinc

  field :number, type: Integer
  field :log_date, type: Date
  field :is_all_approved, type: Mongoid::Boolean, default: 0
  field :is_fuel_filled, type: Mongoid::Boolean, default: 0
  field :is_flight_released, type: Mongoid::Boolean, default: 0
  field :is_flight_booked, type: Mongoid::Boolean, default: 0
  field :is_pilot_back, type: Mongoid::Boolean, default: 0

  #validates :number, presence: true

  increments :number, seed: 1000


  belongs_to :aircraft
  belongs_to :location

  has_one :ac_configuration
  has_one :fuel
  has_one :capt_acceptance_certificate
  has_one :sortie
  has_one :capt_after_flight
  has_one :flightline_release
  has_one :aircraft_total_time
  has_one :after_flight_servicing
  has_one :flightline_servicing
  has_many :techlogs

  # embeds_many :notifications, as: :notifiable

  accepts_nested_attributes_for :ac_configuration
  accepts_nested_attributes_for :fuel
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
    if self.flightline_servicing.inspection_performed == :Preflight
      wucs = WorkUnitCode.preflight
    elsif self.flightline_servicing.inspection_performed == :Thru_Flight
      wucs = WorkUnitCode.thru_flight
    elsif self.flightline_servicing.inspection_performed == :Post_Flight
      wucs = WorkUnitCode.post_flight
    end
    wucs.each do |work|
      Techlog.create({type: :Flight, log_status: :techlog, log_time: "#{Time.now.strftime("%H:%M %p")}", 
        description: self.flightline_servicing.inspection_performed, work_unit_code: work.id})
    end
  end

end
