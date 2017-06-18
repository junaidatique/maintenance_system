class Aircraft
  require 'autoinc'

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Autoinc


  validates :name, presence: true

  field :number, type: Integer
  field :name, type: String
  field :status, type: Mongoid::Boolean
  #field :log_number_inc, type: Integer


  scope :active, -> { where(status: 1) }

  has_many :flying_logs
  increments :number, seed: 1000

end