class LimitationRectification
  include Mongoid::Document

  field :description, type: String
  field :log_date, type: String
  field :log_time, type: String

  belongs_to :limitation_log
  belongs_to :user

end
