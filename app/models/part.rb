class Part
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  as_enum :trade, airframe: 0, engine: 1, electric: 2, instrument: 3, radio: 4
  as_enum :track_from, installation_date: 0, manufacturing_date: 1, no_track: 2
  as_enum :duration, day: 0, month: 1, year: 2

  field :number, type: String
  field :noun, type: String
  field :unit_of_issue, type: String 
  field :location, type: String

  field :contract_quantity, type: Float, default: 0
  field :recieved_quantity, type: Float, default: 0
  field :quantity, type: Float, default: 0 # Store balance
  field :system_quantity, type: Float, default: 0 # Store balance

  field :is_inspectable, type: Mongoid::Boolean
  field :inspection_duration, type: Integer
  field :inspection_hours, type: Float, default: nil
  field :inspection_calender_value, type: Integer

  field :is_lifed, type: Mongoid::Boolean
  field :lifed_duration, type: Integer
  field :lifed_hours, type: Float, default: 0 # life hours or calender life
  field :lifed_calender_value, type: Integer # calender life. either calender life or life hours, this is the number in years
  
  field :is_serialized, type: Mongoid::Boolean

  scope :serialized, -> { where(is_serialized: true) }  
  scope :lifed, -> { where(is_lifed: true) }  
  scope :inspectable, -> { where(is_inspectable: true) }  

  has_one :change_part
  has_many :part_items
  
  before_create :set_inspection_values  
  before_update :set_inspection_values  
  after_create :set_inspections
  
  def set_inspection_values
    if (lifed_calender_value.present? and lifed_calender_value > 0) or (lifed_hours.present? and lifed_hours > 0)
      self.is_lifed = true
    else
      self.is_lifed = false
    end
    # this calculates that if the part is inspectable. 
    if (inspection_hours.present? and inspection_hours > 0) or 
      (inspection_calender_value.present? and inspection_calender_value > 0)
      self.is_inspectable = true
    else
      self.is_inspectable = false
    end
  end
  
  def set_inspections
    if is_lifed? and Inspection.to_replaces.where(part_number: self.number).count == 0
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
    if is_inspectable? and Inspection.to_inspects.where(part_number: self.number).where(is_repeating: true).count == 0
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
  AIRCRAFT_PART_COMP_HOURS = 10
  
  AIRCRAFT_PART_TRADE         = 11
  AIRCRAFT_PART_LAST_CALANDER_INSP = 12
  AIRCRAFT_PART_INSTALL_HOUR  = 13
  AIRCRAFT_PART_LANDINGS = 14
  
  NUMBER            = 1
  NOUN              = 2
  UNIT              = 3
  CONTRACT_QUANTITY = 4
  RECIEVED_QUANTITY = 5
  STORE_BALANCE     = 7
  LOCATION          = 8
  COMPLETED_HOURS   = 9
  INSTALLED_DATE    = 10
  MANU_DATE         = 11
  SERIAL_NO         = 12
  LIFE_CALENDER     = 13
  LIFE_HOUR         = 14
  INSP_CALENDER     = 15
  INSP_HOUR         = 16
  LANDING_COMPLETED = 17
  
  def self.import(file)    
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    (2..xlsx.last_row).each do |i|
      row               = xlsx.row(i)
      # part data 
      number            = row[Part::NUMBER]
      noun              = row[Part::NOUN]
      unit_of_issue     = row[Part::UNIT]
      contract_quantity = row[Part::CONTRACT_QUANTITY]
      recieved_quantity = row[Part::RECIEVED_QUANTITY]
      quantity          = row[Part::STORE_BALANCE]
      location            = row[Part::LOCATION]

      # formulate inspection 
      inspection_hours  = (row[Part::INSP_HOUR].present?) ? row[Part::INSP_HOUR].downcase.gsub("hrs",'').strip.to_i : nil
      inspection_calender_value = nil
      if row[Part::INSP_CALENDER].present?
        if row[Part::INSP_CALENDER].downcase.count('y') > 0
          inspection_calender_value = row[Part::INSP_CALENDER].downcase.gsub("year",'').strip.to_i
          inspection_duration = 2
        else
          inspection_calender_value = row[Part::INSP_CALENDER].downcase.gsub("month",'').strip.to_i
          inspection_duration = 1
        end
      end

      # formulate life
      lifed_calender_value   = nil
      if row[Part::LIFE_CALENDER].present?
        if row[Part::LIFE_CALENDER].downcase.count('y') > 0
          lifed_calender_value = row[Part::LIFE_CALENDER].downcase.gsub("year",'').strip.to_i
          lifed_duration = 2
        else
          lifed_calender_value = row[Part::LIFE_CALENDER].downcase.gsub("month",'').strip.to_i
          lifed_duration = 1
        end
      end      
      lifed_hours  = (row[Part::LIFE_HOUR].present?) ? row[Part::LIFE_HOUR].downcase.gsub("hrs",'').strip.to_f : 0

      # manufactoring or installing date 
      if row[Part::INSTALLED_DATE].present?
        if row[Part::INSTALLED_DATE].is_a? Date        
          installed_date      = DateTime.strptime(row[Part::INSTALLED_DATE].to_s, '%Y-%m-%d')
        else
          installed_date      = DateTime.strptime(row[Part::INSTALLED_DATE].to_s, '%m/%d/%Y')
        end
        if !installed_date.is_a? Date
          puts 'installed date is not a date'
        end
      end

      if row[Part::MANU_DATE].present?
        if row[Part::MANU_DATE].is_a? Date        
          manufacturing_date      = DateTime.strptime(row[Part::MANU_DATE].to_s, '%Y-%m-%d')
        else
          manufacturing_date      = DateTime.strptime(row[Part::MANU_DATE].to_s, '%m/%d/%Y')
        end
        if !manufacturing_date.is_a? Date
          puts 'manufacturing date is not a date'
        end
      end

      if manufacturing_date.present?
        track_from = :manufacturing_date
      elsif installed_date.present?
        track_from = :installation_date
      else
        track_from = :no_track
      end


      part = Part.where(number: number).first
      
      if part.blank?        
        part_data = {
          number: number,                         
          noun: noun,
          unit_of_issue: unit_of_issue,
          track_from: track_from,                                     

          inspection_duration: inspection_duration, 
          inspection_hours: inspection_hours, 
          inspection_calender_value: inspection_calender_value,

          lifed_duration: lifed_duration,
          lifed_calender_value: lifed_calender_value,
          lifed_hours: lifed_hours,
          contract_quantity: contract_quantity,
          recieved_quantity: recieved_quantity,
          system_quantity: quantity,
          quantity: quantity,
          location: location,
        }
        part = Part.create!(part_data)
      else
        part_data = {
          number: number,                         
          noun: noun,
          unit_of_issue: unit_of_issue,          
          contract_quantity: contract_quantity,
          recieved_quantity: recieved_quantity,
          system_quantity: quantity,
          quantity: quantity,
          location: location,
        }
        part.update(part_data)
      end

      #part item data
      serial_no           = row[Part::SERIAL_NO]
      completed_hours     = (row[Part::COMPLETED_HOURS]).present? ? row[Part::COMPLETED_HOURS].to_s.downcase.gsub("hrs",'').strip.to_i : 0
      landings_completed  = (row[Part::LANDING_COMPLETED]).present? ? row[Part::LANDING_COMPLETED].downcase.gsub("hrs",'').strip.to_i : 0   
      

      is_lifed_part = false
      if (lifed_calender_value.present? and lifed_calender_value > 0) or (lifed_hours.present? and lifed_hours > 0)
        is_lifed_part = true
      end
      is_inspectable_part = false
      # this calculates that if the part is inspectable. 
      if (inspection_hours.present? and inspection_hours > 0) or 
        (inspection_calender_value.present? and inspection_calender_value > 0)
        is_inspectable_part = true
      end

      part_item_data = {
        part_id: part.id,                    
        serial_no: serial_no, 
        completed_hours: completed_hours,
        installed_date: installed_date,
        manufacturing_date: manufacturing_date,
        landings_completed: landings_completed,
        location: location,
      }      
      if serial_no.present?
        part_item = PartItem.where(part_id: part.id).where(serial_no: serial_no).first
        if part_item.present?
          # part_item = part_item.update(part_item_data)
        else
          part_item = PartItem.create!(part_item_data)
        end
      else
        if is_lifed_part == true or is_inspectable_part == true
          (1..quantity).each do |part_quantity|
            part_item = PartItem.create!(part_item_data)
          end
        end      
      end
      
    end
  end
end
