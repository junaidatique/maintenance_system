class FlyingPlan
  include Mongoid::Document
  include Mongoid::Timestamps

  field :flying_date, type: Date
  field :reason, type: String
  field :is_flying, type: Mongoid::Boolean

  has_and_belongs_to_many :aircrafts
end
