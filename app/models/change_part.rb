class ChangePart
  include Mongoid::Document

  field :part_number, type: String
  field :quantity_required, type: Float, default: 0
  field :quantity_provided, type: Float, default: 0
  field :available, type: Mongoid::Boolean, default: 1
  field :provided, type: Mongoid::Boolean, default: 0

  belongs_to :requested_by, :class_name => "User"
  belongs_to :assigned_by, :class_name => "User", optional: true

  belongs_to :techlog, inverse_of: :change_parts
  belongs_to :old_part, class_name: 'Part', optional: true, inverse_of: :old_parts  
  belongs_to :new_part, class_name: 'Part', optional: true, inverse_of: :new_parts

  validate :verify_part_number
  validate :verify_quantity_provided
  after_create :change_old_part
  after_update :update_parts_quantity
  

  def change_old_part
    part = Part.where(number: part_number).where(aircraft: self.techlog.aircraft).first
    unless part.blank?
      self.old_part = part
      self.save
    end
  end

  def verify_part_number
    if Part.where(number: part_number).count == 0
      errors.add(:part_number, "is invalid.")
    end
  end

  def verify_quantity_provided      
    if new_part.present? and !provided
      if quantity_provided > new_part.quantity and new_part.serial_no.blank?        
        errors.add(:quantity_provided, "Provided quantity not available.")
      end
    end    
  end  
  
  def update_parts_quantity      
    if new_part.present? and provided_changed?
      if old_part.present? and old_part.serial_no.present?        
        old_part.aircraft = nil        
        old_part.save
      end
      if new_part.serial_no.present?        
        if new_part.category_cd == 0          
          if new_part.aircraft.present?
            techlog.aircraft.create_engine_history 'installed', new_part.aircraft.tail_number, new_part
          end
          if new_part.aircraft.present?
            new_part.aircraft.create_engine_history 'removed', techlog.aircraft.tail_number
          end
        end        
        new_part.aircraft_id = techlog.aircraft_id
      else      
        new_part.quantity = new_part.quantity.to_f - quantity_provided.to_f
      end
      new_part.save
    end  
    
  end

end
