class ChangePart
  include Mongoid::Document

  field :quantity_required, type: Float, default: 0
  field :quantity_provided, type: Float, default: 0
  field :available, type: Mongoid::Boolean, default: 1
  field :provided, type: Mongoid::Boolean, default: 0

  belongs_to :requested_by, :class_name => "User"
  belongs_to :assigned_by, :class_name => "User", optional: true

  belongs_to :techlog, inverse_of: :change_parts
  belongs_to :old_part, class_name: 'Part', inverse_of: :old_parts  
  belongs_to :new_part, class_name: 'Part', optional: true, inverse_of: :new_parts

  validate :verify_quantity_provided
  after_update :update_parts_quantity
  
  def verify_quantity_provided  
    puts self.inspect    
    if new_part.present? and !provided
      if quantity_provided > new_part.quantity_left
        puts 'here'
        errors.add(:quantity_provided, "Provided quantity not available.")
      end
    end    
  end  
  
  def update_parts_quantity  
    if provided_changed?
      old_part.aircraft = nil
      old_part.quantity_left = old_part.quantity_left.to_f + quantity_required.to_f
      old_part.save
      new_part.aircraft_id = techlog.aircraft_id
      new_part.quantity_left = new_part.quantity_left.to_f - quantity_provided.to_f
      new_part.save
    end  
    
  end

end
