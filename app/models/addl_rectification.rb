class AddlRectification
  include Mongoid::Document

  field :description, type: String
  field :log_date, type: String
  field :log_time, type: String

  belongs_to :addl_log
  belongs_to :user

end
