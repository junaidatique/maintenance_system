class Part
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  as_enum :trade, airframe: 0, engine: 1, electric: 2, instrument: 3, radio: 4
  as_enum :track_from, installation_date: 0, manufacturing_date: 1, no_track: 2

  field :number, type: String
  field :noun, type: String
  field :unit_of_issue, type: String 

  field :is_inspectable, type: Mongoid::Boolean
  field :inspection_duration, type: Integer
  field :inspection_hours, type: Float, default: nil
  field :inspection_calender_value, type: Integer

  field :is_lifed, type: Mongoid::Boolean
  field :lifed_duration, type: Integer
  field :lifed_hours, type: Float, default: 0 # life hours or calender life
  field :lifed_calender_value, type: Integer # calender life. either calender life or life hours, this is the number in years
  
  has_many :part_items
  
  before_create :set_inspection_values  
  after_create :set_inspections
  
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
        }
      if part.blank?        
        part = Part.create!(part_data)
      else
        # part.update(part_data)
      end

      #part item data
      serial_no           = row[Part::SERIAL_NO]
      completed_hours     = (row[Part::COMPLETED_HOURS]).present? ? row[Part::COMPLETED_HOURS].downcase.gsub("hrs",'').strip.to_i : 0
      landings_completed  = (row[Part::LANDING_COMPLETED]).present? ? row[Part::LANDING_COMPLETED].downcase.gsub("hrs",'').strip.to_i : 0
      contract_quantity = row[Part::CONTRACT_QUANTITY]
      recieved_quantity = row[Part::RECIEVED_QUANTITY]
      quantity          = row[Part::STORE_BALANCE]
      location          = row[Part::LOCATION]


      part_item_data = {
        part_id: part.id,                    
        serial_no: serial_no, 
        completed_hours: completed_hours,
        installed_date: installed_date,
        manufacturing_date: manufacturing_date,
        landings_completed: landings_completed,
        contract_quantity: contract_quantity,
        recieved_quantity: recieved_quantity,
        quantity: quantity,
        location: location,
      }

      if serial_no.present?
        part_item = PartItem.where(part_id: part.id).where(serial_no: serial_no).first      
      end
      if part_item.present?
        part_item.update(part_item_data)
      else
        part_item = PartItem.create(part_item_data)
      end      
    end
  end
end
