class PartHistory
  include Mongoid::Document

  field :number, type: String
  field :description, type: String
  field :serial_no, type: String
  field :quantity, type: Integer

  field :calender_life, type: Date
  field :installed_date, type: Date

  field :total_part_hours, type: Float, default: 0
  field :remaining_hours, type: Float, default: 0
  field :part_hours_completed, type: Float, default: 0

  field :total_landings, type: Integer
  field :landings_completed, type: Integer, default: 0
  field :landings_remaining, type: Integer, default: 0

  field :is_lifed, type: Mongoid::Boolean
  field :aircraft, type: String

  embedded_in :part
end
