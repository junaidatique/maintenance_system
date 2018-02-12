class ChangePart
  include Mongoid::Document

  field :quantity_required, type: Float, default: 0
  field :quantity_provided, type: Float, default: 0

  belongs_to :requested_by, :class_name => "User", optional: true
  belongs_to :assigned_by, :class_name => "User", optional: true

  belongs_to :techlog, inverse_of: :change_parts
  belongs_to :old_part, class_name: 'Part', inverse_of: :old_parts  
  belongs_to :new_part, class_name: 'Part', optional: true, inverse_of: :new_parts

  validate :verify_quantity_requested

  def verify_quantity_requested
    if quantity_required > old_part.quantity_left
      errors.add(:quantity_required, "Requested quantity not available.")
    end
  end

end
