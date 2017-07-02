class WorkUnitCode
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Tree
  include Mongoid::Tree::Ordering

  field :code, type: String
  field :description, type: String
  field :is_pre_flight, type: Mongoid::Boolean, default: 0
  field :is_thru_flight, type: Mongoid::Boolean, default: 0
  field :is_post_flight, type: Mongoid::Boolean, default: 0
  field :is_crew_cheif, type: Mongoid::Boolean, default: 0

  has_many :techlogs
  has_and_belongs_to_many :user, class_name: User.name

  scope :preflight, -> { where(is_pre_flight: 1) }
  scope :thru_flight, -> { where(is_thru_flight: 1) }
  scope :post_flight, -> { where(is_post_flight: 1) }

  validates :code, :description, presence: true

  accepts_nested_attributes_for :children
end
