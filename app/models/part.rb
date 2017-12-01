class Part
  include Mongoid::Document
  include Mongoid::Timestamps


  validates :number, presence: true
  validates :description, presence: true

  field :number, type: String
  field :description, type: String
  field :serial_no, type: String
  field :quantity, type: Integer

  field :calender_life, type: Date
  field :installed_date, type: Date

  field :total_part_hours, type: Float, default: 0
  field :remaining_hours, type: Float, default: 0
  field :part_hours_completed, type: Float, default: 0

  field :total_landings, type: Integer
  field :landings_completed, type: Integer, default: 0
  field :landings_remaining, type: Integer, default: 0

  field :is_lifed, type: Mongoid::Boolean

  belongs_to :aircraft
  embeds_many :part_histories
  # has_one :old_part, class_name: 'ChangePart' 
  # has_one :new_part, class_name: 'ChangePart'

  # accepts_nested_attributes_for :old_part
  # accepts_nested_attributes_for :new_part

  after_create :update_record
  after_update :create_history

  def create_history
    part_history = PartHistory.new
    part_history.number = self.number
    part_history.description = self.description
    part_history.total_landings = self.total_landings
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
    puts xlsx.inspect
    header = xlsx.row(1)
    puts header.inspect
    (2..xlsx.last_row).each do |i|
      # row = Hash[[header, xlsx.row(i)].transpose]
      # puts row.inspect
      row = xlsx.row(i)
      puts row[0].inspect
      
      aircraft = Aircraft.where(tail_number: row[0]).first
      unless aircraft.blank?
        part_number = row[1]
        serial_no   = row[2]
        description = row[3]
        is_lifed    = row[4]
        calender_life    = row[5]
        installed_date    = row[6]
        total_part_hours    = row[7]
        part_hours_completed    = row[8]
        total_landings    = row[9]
        landings_completed    = row[10]
        part = Part.where(number: part_number)
        if part.present?
          part.update({
            serial_no: serial_no, 
            description: description, 
            is_lifed: is_lifed, calender_life: calender_life, installed_date: installed_date, 
            total_part_hours: total_part_hours,part_hours_completed: part_hours_completed,
            total_landings: total_landings, landings_completed: landings_completed })
        else
          Part.create({
            aircraft: aircraft, 
            number: part_number, 
            serial_no: serial_no, 
            description: description, 
            is_lifed: is_lifed, calender_life: calender_life, installed_date: installed_date, 
            total_part_hours: total_part_hours,part_hours_completed: part_hours_completed,
            total_landings: total_landings, landings_completed: landings_completed })
        end
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
