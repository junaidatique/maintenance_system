class AcConfiguration
  include Mongoid::Document
  include SimpleEnum::Mongoid

  field :clean, type: Mongoid::Boolean
  field :smoke_pods, type: Mongoid::Boolean
  field :fuel_tanks, type: Mongoid::Boolean

  as_enum :cockpit, single: 1, dual: 2

  belongs_to :flying_log

end
