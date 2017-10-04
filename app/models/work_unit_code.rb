class WorkUnitCode
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Tree
  include Mongoid::Tree::Ordering
  include SimpleEnum::Mongoid

  as_enum :wuc_type, Preflight: 0, Thru_Flight: 1, Post_Flight: 2, Other: 3

  field :code, type: String
  field :description, type: String


  has_many :techlogs
  has_and_belongs_to_many :user, class_name: User.name

  scope :preflight, -> { where(wuc_type_cd: 0) }
  scope :thru_flight, -> { where(wuc_type_cd: 1) }
  scope :post_flight, -> { where(wuc_type_cd: 2) }
  scope :other, -> { where(wuc_type_cd: 3) }

  validates :code, :description, presence: true

  accepts_nested_attributes_for :children
end
