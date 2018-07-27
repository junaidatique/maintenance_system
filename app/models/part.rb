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

  field :inspection_duration, type: Integer
  field :inspection_hours, type: Float, default: 0
  field :inspection_calender_value, type: String  
  field :is_inspectable, type: Mongoid::Boolean

  field :is_servicable, type: Mongoid::Boolean, default: true

  field :is_lifed, type: Mongoid::Boolean
  field :calender_life_value, type: Integer # calender life. either calender life or life hours
  field :calender_life_date, type: Date # calender life. either calender life or life hours
  field :installed_date, type: Date

  field :total_hours, type: Float, default: 0 # life hours or calender life
  field :remaining_hours, type: Float, default: 0
  field :completed_hours, type: Float, default: 0
  
  field :landings_completed, type: Integer, default: 0  

  belongs_to :aircraft, optional: true
  
  has_many :part_histories  
  has_many :old_parts, class_name: 'ChangePart', inverse_of: :old_parts
  has_many :new_parts, class_name: 'ChangePart', inverse_of: :new_parts  
  has_many :left_tyre_histories, class_name: 'LandingHistory', inverse_of: :left_tyre  
  has_many :right_tyre_histories, class_name: 'LandingHistory', inverse_of: :right_tyre  
  has_many :nose_tail_histories, class_name: 'LandingHistory', inverse_of: :nose_tail  
  has_many :scheduled_inspections, as: :inspectable

  scope :lifed, -> { where(is_lifed: true) }  
  scope :tyre, -> { any_of({category_cd: 2}, {category_cd: 3}, {category_cd: 4})}
  scope :left_tyre, -> { any_of({category_cd: 2})}
  scope :right_tyre, -> { any_of({category_cd: 3})}
  scope :nose_tail, -> { any_of({category_cd: 4})}
  scope :engine_part, -> { where({category_cd: 0})}
  scope :propeller_part, -> { where({category_cd: 1})}

  validates :number, presence: true
  validates :description, presence: true

  before_create :set_category  
  after_create :update_record
  after_update :check_inspections
  
  def set_category    
    if number == 'ENPL-RT10227' 
      self.category_cd = 0
    elsif number == 'HC-C2YK-1BF I/L C2K00180'
      self.category_cd = 1
    end
  end
  
  def update_record    
    self.number_serial_no = "#{number}-#{serial_no}"
    if (total_hours.present? and completed_hours.present?)
      self.remaining_hours = (total_hours.to_f - completed_hours.to_f).round(2)
    end
    self.calender_life_date = nil
    if (installed_date.present? and calender_life_value.present? and calender_life_value > 0)
      self.calender_life_date = installed_date.to_date + calender_life_value.years      
    end
    if calender_life_value.present? and total_hours.present? and calender_life_value > 0 or total_hours > 0
      self.is_lifed = true
    end
    self.is_inspectable    = ((inspection_hours.present? and inspection_hours > 0) or inspection_calender_value.present?) ? true : false    
    if category_cd == 0 or category_cd == 1
      self.is_inspectable = true
    end
    self.save

    part_history = PartHistory.new         
    part_history.quantity     = self.quantity
    part_history.hours        = self.completed_hours
    part_history.landings     = self.landings_completed
    part_history.flying_log   = nil
    part_history.aircraft_id  = self.aircraft.id if aircraft.present?
    part_history.created_at   = Time.zone.now
    part_history.part         = self      
    part_history.save
    
  end

  def check_inspections    
    if self.is_inspectable?      
      if Inspection.to_be_inspected.where(part_number: self.number).count == 0 and ((inspection_hours.present? and inspection_hours > 0) or inspection_calender_value.present?)
        Inspection.create!({kind_cd: 1, type_cd: 1, name: "#{self.description} Inspection", no_of_hours: inspection_hours, calender_value: inspection_calender_value, duration_cd: self.inspection_duration, part_number: self.number})
      end
      part_inspections = Inspection.to_be_inspected.where(part_number: self.number)
      part_inspections.each do |part_inspection| 
        part_inspection.create_part_inspection self
      end
    end
    if self.is_lifed? and ((self.installed_date.present? and self.calender_life_value > 0) or self.total_hours > 0)
      if Inspection.to_be_replaced.where(part_number: self.number).count == 0
        Inspection.create!({kind_cd: 0, type_cd: 1, name: "#{self.description} Replacement", no_of_hours: total_hours, calender_value: calender_life_value, duration_cd: 2, part_number: self.number})
      end
      part_inspections = Inspection.to_be_replaced.where(part_number: self.number)
      part_inspections.each do |part_inspection| 
        part_inspection.create_part_repalcement self
      end
    end
  end

  def create_history_with_flying_log flying_log
    if self.is_lifed?
      part_history = PartHistory.where(flying_log_id: flying_log.id).where(part_id: self.id).first            
      if part_history.blank?      
        part_history = PartHistory.new         
      end
      
      part_history.quantity     = self.quantity
      part_history.hours        = flying_log.sortie.flight_time
      part_history.landings     = flying_log.sortie.total_landings
      part_history.flying_log   = flying_log
      part_history.aircraft_id  = flying_log.aircraft.id
      part_history.created_at   = flying_log.created_at
      part_history.part         = self      
      part_history.save        
      self.update_values      
    end    
  end

  def update_values
    self.completed_hours     = part_histories.sum('hours')
    self.landings_completed  = part_histories.sum('landings')
    self.remaining_hours     = (total_hours.to_f - completed_hours.to_f).round(2)
    save
    # self.scheduled_inspections.not_completed.inspection.first.update_scheduled_inspections self.completed_hours
    self.scheduled_inspections.not_completed.each do |scheduled_inspection|
      scheduled_inspection.update_scheduled_inspections self.completed_hours      
    end
  end

  

  AIRCRAFT_PART_TAIL_NO  = 1
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

  AIRCRAFT_PART_NUMBER        = 1
  AIRCRAFT_PART_DESCRIPTION   = 2 
  AIRCRAFT_PART_SERIAL_NO     = 3
  AIRCRAFT_PART_LIFE_CALENDER = 4
  AIRCRAFT_PART_LIFE_HOUR     = 5
  AIRCRAFT_PART_INSP_CALENDER = 6
  AIRCRAFT_PART_INSP_HOUR     = 7
  AIRCRAFT_PART_INSTALLED_DATE= 8
  AIRCRAFT_PART_TRADE         = 10
  

  def self.import(file)    
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    (4..xlsx.last_row).each do |i|
      row               = xlsx.row(i)      
      aircraft          = Aircraft.where(tail_number: row[Part::AIRCRAFT_PART_TAIL_NO]).first
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


      calender_life_value   = 
        (row[Part::LIFE_CALENDER].present?) ? row[Part::LIFE_CALENDER].downcase.gsub("year",'').strip.to_i : 0
      total_hours  = (row[Part::LIFE_HOUR].present?)? row[Part::LIFE_HOUR].downcase.gsub("hrs",'').strip.to_i : 0

      installed_date      = row[Part::INSTALLED_DATE]
      completed_hours     = row[Part::COMPLETED_HOURS]
      landings_completed  = row[Part::LANDING_COMPLETED]
      
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

            inspection_duration: inspection_duration, 
            inspection_hours: inspection_hours, 
            inspection_calender_value: inspection_calender_value,

            calender_life_value: calender_life_value,            
            total_hours: total_hours,
                        
            completed_hours: completed_hours,
            installed_date: installed_date,
            landings_completed: landings_completed
          }            
      
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
