class Part
  include Mongoid::Document
  include Mongoid::Timestamps


  field :number, type: String
  field :description, type: String
  field :serial_no, type: String
  field :number_serial_no, type: String
  field :unit_of_issue, type: String

  field :contract_quantity, type: Float, default: 0
  field :recieved_quantity, type: Float, default: 0
  field :quantity, type: Float, default: 0 # Store balance
  field :quantity_left, type: Float, default: 0
  field :dfim_balance, type: Mongoid::Boolean
  field :is_repairable, type: Mongoid::Boolean
  field :inspection_hours, type: Float, default: 0
  field :is_inspectable, type: Mongoid::Boolean
  field :condemn, type: String

  field :is_lifed, type: Mongoid::Boolean
  field :calender_life_value, type: String # calender life. either calender life or life hours
  field :calender_life_date, type: Date # calender life. either calender life or life hours
  field :installed_date, type: Date

  field :total_hours, type: Float, default: 0 # life hours or calender life
  field :remaining_hours, type: Float, default: 0
  field :hours_completed, type: Float, default: 0

  field :total_landings, type: Integer
  field :landings_completed, type: Integer, default: 0
  field :landings_remaining, type: Integer, default: 0

  

  belongs_to :aircraft, optional: true 
  embeds_many :histories, as: :historyable
  has_many :old_parts, class_name: 'ChangePart', inverse_of: :old_parts
  has_many :new_parts, class_name: 'ChangePart', inverse_of: :new_parts  


  validates :number, presence: true
  validates :description, presence: true

  after_create :update_record
  # after_update :create_history
  
  def create_history
    part_history = History.new
    part_history.entry = self.to_json    
    part_history.created_at = Time.now
    # part_history.save
    self.histories << part_history
  end

  def update_record
    self.remaining_hours = self.total_hours.to_f - self.hours_completed.to_f
    self.landings_remaining = self.total_landings.to_i - self.landings_completed.to_i
    self.save
  end

  def self.import(file)    
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    (4..xlsx.last_row).each do |i|
      row                   = xlsx.row(i)
      puts row.inspect
      number                = row[1]
      description           = row[2]
      unit_of_issue         = row[3]
      contract_quantity     = row[4]
      recieved_quantity     = row[5]
      quantity              = row[6]
      dfim_balance          = (row[7].present? and row[7].downcase == 'y') ? true : false
      is_repairable         = (row[8].present? and row[8].downcase == 'y') ? true : false
      inspection_hours      = (row[9].present?) ? row[9].downcase.gsub("hrs",'').strip.to_i : 0
      is_inspectable        = (inspection_hours.blank?) ? false : true
      condemn               = row[10]
      calender_life_value   = (row[11].present?) ? row[11].downcase.gsub("year",'').strip.to_i : 0
      total_hours           = (row[12].present?) ? row[12].downcase.gsub("hrs",'').strip.to_i : 0
      serial_no             = row[13]
      is_lifed = false
      if !calender_life_value.blank? or !total_hours.blank?
        is_lifed = true
      end
      part = Part.where(number: number).first
      part_number_serial_no = "#{number}-#{serial_no}"
      part_data = {            
            number: number, 
            serial_no: serial_no, 
            number_serial_no: part_number_serial_no, 
            description: description, 
            unit_of_issue: unit_of_issue, 
            quantity: quantity, 
            contract_quantity: contract_quantity, 
            recieved_quantity: recieved_quantity,             
            dfim_balance: dfim_balance, 
            is_repairable: is_repairable, 
            inspection_hours: inspection_hours, 
            is_inspectable: is_inspectable, 
            condemn: condemn, 
            is_lifed: is_lifed, 
            calender_life_value: calender_life_value,             
            total_hours: total_hours,            
          }
      # puts part_data.inspect
      
      if part.present?
        part.update(part_data)
      else
        part = Part.create(part_data)
      end
      # part.create_history
      # break; 
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
