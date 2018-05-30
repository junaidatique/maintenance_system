class ScheduledInspection
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid
  
  as_enum :status, scheduled: 0, in_progress: 1, completed: 2

  field :hours, type: Float, default: 0
  field :completed_hours, type: Float, default: 0
  field :calender_life_date, type: Date

  belongs_to :inspection
  has_one :techlog
end
