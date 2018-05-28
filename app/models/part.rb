class Part
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  as_enum :category, 
    engine: 0, 
    propeller: 1, 
    left_tyre: 2, 
    right_tyre: 3, 
    nose_tail: 4
    

  as_enum :trade, airframe: 0, engine: 1, electic: 2, instrument: 3, radio: 4

  field :number, type: String
  field :description, type: String
  field :serial_no, type: String
  field :number_serial_no, type: String
  field :unit_of_issue, type: String

  field :contract_quantity, type: Float, default: 0
  field :recieved_quantity, type: Float, default: 0
  field :quantity, type: Float, default: 0 # Store balance

  field :dfim_balance, type: Mongoid::Boolean
  field :is_repairable, type: Mongoid::Boolean
  field :condemn, type: String

  field :inspection_hours, type: Float, default: 0
  field :inspection_calender_value, type: String  
  field :is_inspectable, type: Mongoid::Boolean

  field :is_lifed, type: Mongoid::Boolean
  field :calender_life_value, type: String # calender life. either calender life or life hours
  field :calender_life_date, type: Date # calender life. either calender life or life hours
  field :installed_date, type: Date

  field :total_hours, type: Float, default: 0 # life hours or calender life
  field :remaining_hours, type: Float, default: 0
  field :completed_hours, type: Float, default: 0
  
  field :landings_completed, type: Integer, default: 0  


  belongs_to :aircraft, optional: true
  
  # embeds_many :histories, as: :historyable
  has_many :old_parts, class_name: 'ChangePart', inverse_of: :old_parts
  has_many :new_parts, class_name: 'ChangePart', inverse_of: :new_parts  


  validates :number, presence: true
  validates :description, presence: true

  after_create :update_record
  after_update :create_history
  
  def create_history
    # part_history = History.new
    # part_history.entry = self.to_json    
    # part_history.created_at = Time.now
    # part_history.save
    # self.histories << part_history
  end

  def update_record
    self.remaining_hours = self.total_hours.to_f - self.completed_hours.to_f    
    self.save
  end

  AIRCRAFT_TAIL_NO  = 1
  TRADE             = 2
  NUMBER            = 3
  DESCRIPTION       = 4
  UNIT              = 5
  CONTRACT_QUANTITY = 6
  RECIEVED_QUANTITY = 7
  STORE_BALANCE     = 8
  DFIM              = 9
  REPAIR            = 10
  CONDEMN           = 11
  LIFED             = 12
  INSP_HOUR         = 13
  INSP_CALENDER     = 14
  LIFE_CALENDER     = 15
  LIFE_HOUR         = 16  
  INSTALLED_DATE    = 17
  COMPLETED_HOURS   = 18
  LANDING_COMPLETED = 19
  SERIAL_NO         = 20

  def self.import(file)    
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    (4..xlsx.last_row).each do |i|
      row               = xlsx.row(i)      
      aircraft          = Aircraft.where(tail_number: row[Part::AIRCRAFT_TAIL_NO]).first
      trade             = (Part::categories.include? row[Part::TRADE]) ? row[Part::TRADE] : nil
      number            = row[Part::NUMBER]
      description       = row[Part::DESCRIPTION]
      unit_of_issue     = row[Part::UNIT]

      contract_quantity = row[Part::CONTRACT_QUANTITY]
      recieved_quantity = row[Part::RECIEVED_QUANTITY]
      quantity          = row[Part::STORE_BALANCE]
      dfim_balance      = (row[Part::DFIM].present? and row[Part::DFIM].downcase == 'y') ? true : false

      is_repairable     = (row[Part::REPAIR].present? and row[Part::REPAIR].downcase == 'y') ? true : false
      condemn           = row[Part::CONDEMN]
      is_lifed          = (row[Part::LIFED].present? and row[Part::LIFED].downcase == 'y') ? true : false

      inspection_hours  = (row[Part::INSP_HOUR].present?)? row[Part::INSP_HOUR].downcase.gsub("hrs",'').strip.to_i : 0
      inspection_calender_value = 
        (row[Part::INSP_CALENDER].present?)? row[Part::INSP_CALENDER].downcase.gsub("month",'').strip.to_i : 0
      is_inspectable    = (inspection_hours.present? || inspection_calender_value.present?) ? true : false

      calender_life_value   = 
        (row[Part::LIFE_CALENDER].present?) ? row[Part::LIFE_CALENDER].downcase.gsub("year",'').strip.to_i : 0
      total_hours       = (row[Part::LIFE_HOUR].present?)? row[Part::LIFE_HOUR].downcase.gsub("hrs",'').strip.to_i : 0

      installed_date    = row[Part::INSTALLED_DATE]
      if (installed_date.present?)
        calender_life_date = installed_date.to_date + calender_life_value.years
      end

      completed_hours     = row[Part::COMPLETED_HOURS]
      landings_completed  = row[Part::LANDING_COMPLETED]
      if (total_hours.present? and completed_hours.present?)
        remaining_hours = total_hours.to_f - completed_hours.to_f
      end
      serial_no           = row[Part::SERIAL_NO]
      
      number_serial_no = "#{number}-#{serial_no}"
      part = Part.where(number_serial_no: number_serial_no).first      
      part_data = {            
            aircraft: aircraft, 
            trade: trade, 
            number: number, 
            serial_no: serial_no, 
            number_serial_no: number_serial_no, 
            description: description, 
            unit_of_issue: unit_of_issue, 

            quantity: quantity,            
            contract_quantity: contract_quantity, 
            recieved_quantity: recieved_quantity,    
            dfim_balance: dfim_balance, 

            is_repairable: is_repairable, 
            condemn: condemn, 
            is_lifed: is_lifed, 

            inspection_hours: inspection_hours, 
            inspection_calender_value: inspection_calender_value,             
            is_inspectable: is_inspectable, 
                                                 
            calender_life_value: calender_life_value,
            calender_life_date: calender_life_date,
            total_hours: total_hours,
            
            remaining_hours: remaining_hours,
            completed_hours: completed_hours,
            installed_date: installed_date,
            landings_completed: landings_completed,

          }            
      puts part_data.inspect
      if part.present?
        part.update(part_data)
      else
        part = Part.create(part_data)
      end      
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
