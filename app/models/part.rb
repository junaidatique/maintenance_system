class Part
  include Mongoid::Document
  include Mongoid::Timestamps

  validates :number, presence: true
  validates :serial_no, presence: true
  validates :noun, presence: true
  validates :is_lifed, presence: true

  field :number, type: String
  field :noun, type: String
  field :serial_no, type: String
  field :calender_life, type: Date
  field :installed_date, type: Date
  field :remaining_hours, type: Float
  field :flight_hours_completed, type: Float, default: 0
  field :flight_hours_left, type: Float, default: 0
  field :flight_hours, type: String
  field :no_of_landings, type: String
  field :no_of_landings_completed, type: String, default: 0
  field :is_lifed, type: Mongoid::Boolean

  belongs_to :aircraft
  has_one :old_part, class_name: 'ChangePart' 
  has_one :new_part, class_name: 'ChangePart'

  accepts_nested_attributes_for :old_part
  accepts_nested_attributes_for :new_part

end
