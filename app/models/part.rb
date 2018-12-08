class Part
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  as_enum :category, 
    engine: 0, 
    propeller: 1, 
    left_tyre: 2, 
    right_tyre: 3, 
    nose_tail: 4,
    battery: 5

  as_enum :trade, airframe: 0, engine: 1, electric: 2, instrument: 3, radio: 4
  as_enum :track_from, installation_date: 0, manufacturing_date: 1

  field :number, type: String
  field :noun, type: String

  # field :is_repairable, type: Mongoid::Boolean

  field :is_inspectable, type: Mongoid::Boolean
  field :inspection_duration, type: Integer
  field :inspection_hours, type: Float, default: nil
  field :inspection_calender_value, type: Integer

  
  field :is_lifed, type: Mongoid::Boolean
  field :lifed_duration, type: Integer
  field :lifed_hours, type: Float, default: 0 # life hours or calender life
  field :lifed_calender_value, type: Integer # calender life. either calender life or life hours, this is the number in years
  
  has_many :part_items

  before_create :set_category  
  before_create :set_inspection_values  
  after_create :set_inspections

  def set_category    
    if number == 'ENPL-RT10227' 
      self.category_cd = 0
    elsif number == 'HC-C2YK-1BF I/L C2K00180'
      self.category_cd = 1
    elsif noun == 'MAIN WHEEL LT'
      self.category_cd = 2
    elsif noun == 'MAIN WHEEL RT'
      self.category_cd = 3
    elsif noun == 'NOSE WHEEL'
      self.category_cd = 4
    elsif number == '6127279-067'
      self.category_cd = 5
    end
  end

  def set_inspection_values
    if (lifed_calender_value.present? and lifed_calender_value > 0) or (lifed_hours.present? and lifed_hours > 0)
      self.is_lifed = true
    end
    # this calculates that if the part is inspectable. 
    if (inspection_hours.present? and inspection_hours > 0) or 
      (inspection_calender_value.present? and inspection_calender_value > 0)
      self.is_inspectable = true
    end    
  end
  

  def set_inspections    
    
    if is_lifed? and Inspection.to_be_replaced.where(part_number: self.number).count == 0
      Inspection.create!(
        {
          kind: :to_replace, 
          type: :part, 
          name: "#{self.noun.titleize} Replacement", 
          no_of_hours: self.lifed_hours, 
          calender_value: self.lifed_calender_value, 
          duration_cd: self.lifed_duration, 
          part_number: self.number
        }
      )
    end
    if is_inspectable? and Inspection.to_be_inspected.where(part_number: self.number).where(is_repeating: true).count == 0
      Inspection.create!(
        {
          kind: :to_inspect, 
          type: :part, 
          name: "#{self.noun.titleize} Inspection", 
          no_of_hours: self.inspection_hours, 
          calender_value: self.inspection_calender_value,
          duration_cd: self.inspection_duration, 
          part_number: self.number
        }
      )
    end
  end 

  AIRCRAFT_PART_NUMBER        = 1
  AIRCRAFT_PART_NOUN          = 2 
  AIRCRAFT_PART_SERIAL_NO     = 3
  AIRCRAFT_PART_LIFE_CALENDER = 4
  AIRCRAFT_PART_LIFE_HOUR     = 5
  AIRCRAFT_PART_INSP_CALENDER = 6
  AIRCRAFT_PART_INSP_HOUR     = 7
  AIRCRAFT_PART_INSTALLED_DATE= 8
  AIRCRAFT_PART_MANU_DATE     = 9
  AIRCRAFT_PART_INSTALL_HOUR  = 10
  AIRCRAFT_PART_TRADE         = 11
  AIRCRAFT_PART_LAST_CALANDER_INSP = 12
  AIRCRAFT_PART_LAST_HOUR_INSP = 13
  AIRCRAFT_PART_LANDINGS = 14
end
