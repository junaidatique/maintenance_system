class AcConfiguration
  include Mongoid::Document
  include SimpleEnum::Mongoid
  include Mongoid::Timestamps

  field :clean, type: Mongoid::Boolean
  field :smoke_pods, type: Mongoid::Boolean
  field :third_seat, type: Mongoid::Boolean
  field :smoke_oil_quantity, type: String

  as_enum :cockpit, Single: 1, Dual: 2

  belongs_to :flying_log

end
