class FlyingLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :number, type: String
  field :log_date, type: Date
  field :is_all_approved, type: Mongoid::Boolean, default: 0

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
  has_many :flightline_servicings
  has_many :techlogs

  accepts_nested_attributes_for :ac_configuration
  accepts_nested_attributes_for :fuel
  accepts_nested_attributes_for :capt_acceptance_certificate
  accepts_nested_attributes_for :sortie
  accepts_nested_attributes_for :capt_after_flight
  accepts_nested_attributes_for :flightline_release
  accepts_nested_attributes_for :aircraft_total_time
  accepts_nested_attributes_for :after_flight_servicing
  accepts_nested_attributes_for :flightline_servicings, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :techlogs
end
