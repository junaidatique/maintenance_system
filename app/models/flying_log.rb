class FlyingLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :number, type: String
  field :log_date, type: Date

  belongs_to :aircraft
  belongs_to :location

end
