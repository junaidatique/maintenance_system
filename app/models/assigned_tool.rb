class AssignedTool
  include Mongoid::Document  
  
  field :quantity_required, type: Integer
  field :quantity_assigned, type: Integer
  field :is_returned, type: Mongoid::Boolean, default: 0

  belongs_to :requested_by, :class_name => "User", optional: true
  belongs_to :assigned_by, :class_name => "User", optional: true

  belongs_to :techlog, inverse_of: :assigned_tools
  belongs_to :tool, inverse_of: :assigned_tools
  
  validate :verify_quantity_requested
  validate :verify_quantity_assigned
  after_update :update_quantity

  def verify_quantity_requested
    if quantity_required > tool.quantity_in_hand
      errors.add(:quantity_required, " Requested quantity not available.")
    end
  end
  def verify_quantity_assigned
    if quantity_assigned.present? and quantity_assigned > tool.quantity_in_hand
      errors.add(:quantity_assigned, " Assinged quantity not available.")
    end
    if quantity_assigned.present? and quantity_assigned > quantity_required
      errors.add(:quantity_assigned, " You can't assign more than requested quantity.")
    end
  end
  def update_quantity
    if !is_returned
      if quantity_assigned_was.present?
        tool.quantity_in_hand = tool.quantity_in_hand.to_i + quantity_assigned_was.to_i
        tool.save
      end
      tool.quantity_in_hand = tool.quantity_in_hand.to_i - quantity_assigned.to_i
      tool.save
    else 
      tool.quantity_in_hand = tool.quantity_in_hand.to_i + quantity_assigned_was.to_i
      tool.save
    end
    
    
  end
end
