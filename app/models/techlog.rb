class Techlog
  include Mongoid::Document

  field :number, type: String
  field :description, type: String

  belongs_to :user
  belongs_to :flying_log
end
