class TechnicalOrder
  include Mongoid::Document
  include Mongoid::Timestamps

  field :version_number, type: Float, default: 0.0
  field :name, type: String

  has_many :technical_changes, class_name: Change.name, inverse_of: :technical_order
end
