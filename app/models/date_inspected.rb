class DateInspected
  include Mongoid::Document

  field :work_date, type: String
  field :work_time, type: String
  
  belongs_to :user
  belongs_to :techlog
end
