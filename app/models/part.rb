class Part
  include Mongoid::Document
  include Mongoid::Timestamps


  field :number, type: String
  field :description, type: String
  field :serial_no, type: String
  field :number_serial_no, type: String
  field :quantity, type: Float, default: 0
  field :quantity_left, type: Float, default: 0

  field :calender_life, type: Date
  field :installed_date, type: Date

  field :total_part_hours, type: Float, default: 0
  field :remaining_hours, type: Float, default: 0
  field :part_hours_completed, type: Float, default: 0

  field :total_landings, type: Integer
  field :landings_completed, type: Integer, default: 0
  field :landings_remaining, type: Integer, default: 0

  field :is_lifed, type: Mongoid::Boolean

  belongs_to :aircraft, optional: true 
  embeds_many :part_histories
  has_many :old_parts, class_name: 'ChangePart', inverse_of: :old_parts
  has_many :new_parts, class_name: 'ChangePart', inverse_of: :new_parts  


  validates :number, presence: true
  validates :description, presence: true

  after_create :update_record
  after_update :create_history

  def create_history
    part_history = PartHistory.new
    part_history.aircraft = self.aircraft.present? ? self.aircraft.id.to_s : ''
    part_history.number = self.number
    part_history.description = self.description
    part_history.serial_no = self.serial_no
    part_history.quantity = self.quantity
    part_history.quantity_left = self.quantity_left

    part_history.calender_life = self.calender_life
    part_history.installed_date = self.installed_date

    part_history.total_part_hours = self.total_part_hours
    part_history.remaining_hours = self.remaining_hours
    part_history.part_hours_completed = self.part_hours_completed
    
    part_history.total_landings = self.total_landings
    part_history.landings_completed = self.landings_completed
    part_history.landings_remaining = self.landings_remaining
    part_history.part = self
    part_history.save
    #self.part_histories << part_history
  end

  def update_record
    self.remaining_hours = self.total_part_hours.to_f - self.part_hours_completed.to_f
    self.landings_remaining = self.total_landings.to_i - self.landings_completed.to_i    
    self.save
  end

  def self.import(file)    
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)    
    header = xlsx.row(1)    
    (2..xlsx.last_row).each do |i|
      row         = xlsx.row(i)
      aircraft    = Aircraft.where(tail_number: row[0]).first
      part_number = row[1]
      serial_no   = row[2]
      description = row[3]
      quantity    = row[4]
      is_lifed    = row[5]
      calender_life         = row[6]
      installed_date        = row[7]
      total_part_hours      = row[8]
      part_hours_completed  = row[9]
      total_landings        = row[10]
      landings_completed    = row[11]
      part = Part.where(number: part_number)
      part_number_serial_no = "#{part_number}-#{serial_no}"
      if part.present?
        part.update({
          serial_no: serial_no, 
          description: description, 
          quantity: quantity, 
          is_lifed: is_lifed, calender_life: calender_life, installed_date: installed_date, 
          total_part_hours: total_part_hours,part_hours_completed: part_hours_completed,
          total_landings: total_landings, landings_completed: landings_completed })
      else
        Part.create!({
          aircraft: aircraft, 
          number: part_number, 
          serial_no: serial_no, 
          number_serial_no: part_number_serial_no, 
          description: description, 
          quantity: quantity, 
          quantity_left: quantity_left, 
          is_lifed: is_lifed, calender_life: calender_life, installed_date: installed_date, 
          total_part_hours: total_part_hours,part_hours_completed: part_hours_completed,
          total_landings: total_landings, landings_completed: landings_completed })
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
