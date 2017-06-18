class System
  include Mongoid::Document
  include Mongoid::Timestamps

  field :settings, type: Hash
end
