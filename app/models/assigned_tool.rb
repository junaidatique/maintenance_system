class AssignedTool
  include Mongoid::Document  
  
  
  field :serial_no, type: String
  field :is_returned, type: Mongoid::Boolean, default: 0
  field :is_assigned, type: Mongoid::Boolean, default: 0

  belongs_to :assigned_by, :class_name => "User", optional: true
  belongs_to :requested_tool
  belongs_to :tool, optional: true
  
  # after_update :update_quantity
  
  #validates :serial_no, presence: true
  validate :verify_quantity_assigned
  
  def verify_quantity_assigned
    puts self.requested_tool.inspect
    puts self.inspect
    unless is_assigned.blank?      
      if serial_no.blank?        
        errors.add(:serial_no, " is required.")
      end
      tool = Tool.where(number: requested_tool.tool_no).where(serial_no: serial_no).first  
      if tool.blank?        
        errors.add(:serial_no, " is invalid.")
      end      
      if tool.assigned_tools.where(is_returned: false).nin(id: self.id).count > 0
        errors.add(:serial_no, " This tool is already assigned.")
      end      
    end
  end
  def update_quantity
    if tool.blank?
      self.tool_id = Tool.where(number: requested_tool.tool_no).where(serial_no: serial_no).first.id
      self.save    
    end
    if is_returned?
      tool.quantity_in_hand = tool.quantity_in_hand + 1 if tool.quantity_in_hand == 0
    else
      tool.quantity_in_hand = tool.quantity_in_hand - 1 if tool.quantity_in_hand > 0
    end
    tool.save
    if self.requested_tool.assigned_tools.where(is_assigned: false).count == 0
      requested_tool = self.requested_tool
      requested_tool.is_assigned = true
      requested_tool.save
    end
    if self.requested_tool.assigned_tools.where(is_returned: false).count == 0
      requested_tool = self.requested_tool
      requested_tool.is_returned = true
      requested_tool.save
    end
  end
end
