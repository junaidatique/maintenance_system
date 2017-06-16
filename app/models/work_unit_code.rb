class WorkUnitCode
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Tree
  include Mongoid::Tree::Ordering

  field :code, type: String
  field :description, type: String

  has_many :techlogs
  has_and_belongs_to_many :user, class_name: User.name

  validates :code, :description, presence: true

  accepts_nested_attributes_for :children
end
