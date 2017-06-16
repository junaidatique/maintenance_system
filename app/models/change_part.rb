class ChangePart
  include Mongoid::Document

  field :pin_out, type: String
  field :serial_number_out, type: String
  field :pin_in, type: String
  field :serial_number_in, type: String

  belongs_to :techlog
end
