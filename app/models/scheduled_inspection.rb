class ScheduledInspection
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid
  
  as_enum :status, scheduled: 0, pending: 1, in_progress: 2, completed: 3

  field :hours, type: Float, default: 0
  field :completed_hours, type: Float, default: 0
  field :calender_life_date, type: Date
  field :started_date, type: Date
  field :completed_date, type: Date
  
  belongs_to :inspection
  has_one :techlog
  belongs_to :started_by, :class_name => "User", optional: true
end
