class LimitationLog
  require 'autoinc'

  include Mongoid::Document
  include Mongoid::Autoinc

  field :number, type: Integer
  field :description, type: String
  field :limitation, type: String
  field :period_of_deferm, type: String
  field :due, type: String
  field :log_date, type: String
  field :log_time, type: String

  increments :number, seed: 1000

  has_one :limitation_rectification

  belongs_to :techlog
  belongs_to :user, optional: true

  accepts_nested_attributes_for :limitation_rectification

end
