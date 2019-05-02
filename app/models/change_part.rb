class ChangePart
  include Mongoid::Document

  field :part_number, type: String
  field :quantity_required, type: Float, default: 0
  field :quantity_provided, type: Float, default: 0
  field :available, type: Mongoid::Boolean, default: 1
  field :provided, type: Mongoid::Boolean, default: 0
  field :is_servicable, type: Mongoid::Boolean, default: 1

  belongs_to :requested_by, :class_name => "User"
  belongs_to :assigned_by, :class_name => "User", optional: true

  belongs_to :techlog, inverse_of: :change_parts
  belongs_to :part #, class_name: 'Part', optional: true, inverse_of: :old_parts  
  belongs_to :old_part, class_name: 'PartItem', optional: true, inverse_of: :old_parts  
  belongs_to :new_part, class_name: 'PartItem', optional: true, inverse_of: :new_parts

  validate :validate_requested_quantity
  validate :verify_quantity_provided
  # after_create :change_old_part
  # after_update :update_parts_quantity
  

  def validate_requested_quantity
    if quantity_required.to_i == 0
      errors.add(:quantity_required, "is invalid.")
    elsif part.is_serialized? and quantity_required >1
      errors.add(:quantity_required, " is serialized. you can only demand 1 part.")
    elsif part.quantity < quantity_required
      errors.add(:quantity_required, "not in stock.")
    end
    
  end

  def verify_quantity_provided      
    if new_part.present? and !provided
      if !part.is_serialized?
        if quantity_provided > part.quantity
          errors.add(:quantity_provided, "Provided quantity not available.")
        end
      end      
    end    
  end  

  def change_old_part
    if part.part_items.count > 0
      part_item = self.part.part_items.where(aircraft: self.techlog.aircraft).first
      if part_item.present? and self.old_part.blank?
        self.old_part = part_item
        self.save            
      end
      if part_item.present?
        part_item.is_servicable = self.is_servicable     
        part_item.save
      end
    end
  end

  
  
  def update_parts_quantity  
    if provided?    
      if new_part.present? 
        if old_part.present? and old_part.serial_no.present?        
          old_part.aircraft = nil                  
          old_part.save
        end
        if new_part.is_lifed? and new_part.installed_date.blank?
          new_part.installed_date = Time.zone.now
        end
        new_part.category = old_part.category
        new_part.aircraft_installation_date = Time.zone.now
        new_part.aircraft_installation_hours = techlog.aircraft.flight_hours
        new_part.completed_hours_when_installed = new_part.completed_hours
        if new_part.serial_no.present?        
          if new_part.category == :engine
            if new_part.aircraft.present?
              techlog.aircraft.create_engine_history 'installed', new_part.aircraft.tail_number, new_part
            end
            if new_part.aircraft.present?
              new_part.aircraft.create_engine_history 'removed', techlog.aircraft.tail_number
            end
          end        
          new_part.aircraft_id = techlog.aircraft_id                    
        else      
          # new_part.quantity = new_part.quantity.to_f - quantity_provided.to_f
        end
        new_part.save
      end           
    end
  end

end
