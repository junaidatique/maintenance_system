class Location
  include Mongoid::Document
  include Mongoid::Timestamps

  validates :name, presence: true

  field :name, type: String
  field :status, type: Mongoid::Boolean
end
