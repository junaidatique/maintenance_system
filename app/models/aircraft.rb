class Aircraft
  include Mongoid::Document
  include Mongoid::Timestamps


  validates :tail_number, presence: true
  validates :serial_no, presence: true

  field :number, type: Integer
  field :tail_number, type: String
  field :serial_no, type: String
  
  field :status, type: Mongoid::Boolean
  field :available_for_flight, type: Mongoid::Boolean
  
  field :flight_hours, type: Float, default: 0
  field :engine_hours, type: Float, default: 0
  field :landings, type: Integer, default: 0


  scope :active, -> { where(status: 1) }
  scope :available, -> { where(available_for_flight: 1) }

  has_many :flying_logs
  has_many :parts

  accepts_nested_attributes_for :parts, :allow_destroy => true
  

end