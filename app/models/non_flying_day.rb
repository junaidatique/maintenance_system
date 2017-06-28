class NonFlyingDay
  include Mongoid::Document
  include Mongoid::Timestamps

  field :date, type: Date
  field :reason, type: String

end
