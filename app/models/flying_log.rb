class FlyingLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :number, type: String
  field :log_date, type: Date

  belongs_to :aircraft
  belongs_to :location

  has_one :ac_configuration
  has_one :fuel
  has_many :flightline_servicings

  accepts_nested_attributes_for :ac_configuration
  accepts_nested_attributes_for :fuel
  accepts_nested_attributes_for :flightline_servicings, :reject_if => :all_blank, :allow_destroy => true


end
