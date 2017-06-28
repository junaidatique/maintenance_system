class Part
  include Mongoid::Document
  include Mongoid::Timestamps

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

end
