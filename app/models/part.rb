class Part
  include Mongoid::Document
  include Mongoid::Timestamps

  validates :number, presence: true
  validates :serial_no, presence: true
  validates :description, presence: true
  validates :is_lifed, presence: true

  field :number, type: String
  field :description, type: String
  field :serial_no, type: String

  field :calender_life, type: Date
  field :installed_date, type: Date

  field :total_part_hours, type: Float, default: 0
  field :remaining_hours, type: Float, default: 0
  field :part_hours_completed, type: Float, default: 0

  field :total_landings, type: Integer
  field :landings_completed, type: Integer, default: 0
  field :landings_remaining, type: Integer, default: 0

  field :is_lifed, type: Mongoid::Boolean

  belongs_to :aircraft
  # has_one :old_part, class_name: 'ChangePart' 
  # has_one :new_part, class_name: 'ChangePart'

  # accepts_nested_attributes_for :old_part
  # accepts_nested_attributes_for :new_part

  after_create :update_record

  def update_record
    self.remaining_hours = self.total_part_hours.to_f - self.part_hours_completed.to_f
    self.landings_remaining = self.total_landings.to_i - self.landings_completed.to_i
    self.save
  end

end
