class Aircraft
  include Mongoid::Document
  include Mongoid::Timestamps

  field :number, type: String
  field :name, type: String
  field :status, type: Boolean
end