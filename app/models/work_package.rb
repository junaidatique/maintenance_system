class WorkPackage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description, type: String

  belongs_to :inspection
  belongs_to :work_unit_code
end
