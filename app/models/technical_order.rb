class TechnicalOrder
  include Mongoid::Document
  include Mongoid::Timestamps

  field :version_number, type: Float
  
end
