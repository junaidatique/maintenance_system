class WorkUnitCode
  include Mongoid::Document
  include Mongoid::Timestamps

  field :code, type: String
  field :description, type: String

  has_and_belongs_to_many :user, class_name: User.name

  validates :code, :description, presence: true
end
