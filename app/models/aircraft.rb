class Aircraft
  include Mongoid::Document
  include Mongoid::Timestamps

  field :number, type: Integer
  field :tail_number, type: String
  field :serial_no, type: String
  
  field :fuel_capacity, type: Float, default: 0
  field :oil_capacity, type: Float, default: 0
  
  field :type_model, type: String
  field :type_series, type: String

  field :organization, type: String

  field :available_for_flight, type: Mongoid::Boolean
  
  field :flight_hours, type: Float, default: 0
  field :engine_hours, type: Float, default: 0
  field :prop_hours, type: Float, default: 0
  field :landings, type: Integer, default: 0


  validates :tail_number, presence: true
  validates :serial_no, presence: true
  validates :fuel_capacity, presence: true
  validates :oil_capacity, presence: true
  validates_uniqueness_of :tail_number

  scope :active, -> { where(:id.in => FlyingPlan.where(is_flying: true).where(flying_date: Time.zone.now.strftime("%Y-%m-%d")).first.aircrafts.map(&:id)) }
  

  has_many :flying_logs, dependent: :destroy
  has_many :techlogs, dependent: :destroy
  has_many :parts, dependent: :destroy
  has_many :part_histories, dependent: :destroy
  has_many :flying_histories, dependent: :destroy
  has_many :landing_histories, dependent: :destroy
  has_many :scheduled_inspections, as: :inspectable

  accepts_nested_attributes_for :parts, :allow_destroy => true  
    
  def update_part_values flying_log
    self.flight_hours = flying_log.aircraft_total_time.corrected_total_aircraft_hours.to_f
    self.landings     = flying_log.aircraft_total_time.corrected_total_landings.to_f
    self.engine_hours = flying_log.aircraft_total_time.corrected_total_engine_hours.to_f
    self.prop_hours   = flying_log.aircraft_total_time.corrected_total_prop_hours.to_f
    self.save
    self.scheduled_inspections.not_completed.each do |scheduled_inspection|
      scheduled_inspection.update_scheduled_inspections self.flight_hours      
    end
    lifed_parts = self.parts.lifed    
    lifed_parts.each do |part|            
      part.create_history_with_flying_log flying_log
    end    
    tyre_parts = self.parts.tyre
    tyre_parts.each do |part|
      part.create_history_with_flying_log flying_log
    end    
  end

  def create_engine_history type, other_aircraft = nil, part = nil
    previous_history = self.flying_histories.last
    history = FlyingHistory.new 
    history.aircraft              = self
    history.this_aircraft_hours   = 0
    history.total_aircraft_hours  = previous_history.total_aircraft_hours

    history.this_engine_hours     = 0
    

    history.this_prop_hours       = 0
    history.total_prop_hours      = previous_history.total_prop_hours

    history.total_landings  = previous_history.total_landings    
    history.touch_go        = 0
    history.full_stop       = 0
    if type == 'removed'
      history.remarks = "Engine removed and installed to #{other_aircraft}."
      history.total_engine_hours    = 0
    else      
      history.total_engine_hours    = part.completed_hours if part.present? 
      if other_aircraft.present?
        history.remarks = "New Engine installed from #{other_aircraft}."
      else
        history.remarks = "New Engine installed."
      end
    end
    history.save!
  end
  def import file
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    (5..xlsx.last_row).each do |i|
      row               = xlsx.row(i)      
      aircraft          = self
      number            = row[Part::AIRCRAFT_PART_NUMBER].to_s.gsub("\n", '')
      description       = row[Part::AIRCRAFT_PART_DESCRIPTION]
      is_lifed          = true
      inspection_hours  = (row[Part::AIRCRAFT_PART_INSP_HOUR].present?) ? row[Part::AIRCRAFT_PART_INSP_HOUR].downcase.gsub("hrs",'').strip.to_i : 0
      inspection_calender_value = nil
      if row[Part::AIRCRAFT_PART_INSP_CALENDER].present?
        if row[Part::AIRCRAFT_PART_INSP_CALENDER].downcase.count('y') > 0
          inspection_calender_value = row[Part::AIRCRAFT_PART_INSP_CALENDER].downcase.gsub("year",'').strip.to_i
          inspection_duration = 2
        else
          inspection_calender_value = row[Part::AIRCRAFT_PART_INSP_CALENDER].downcase.gsub("month",'').strip.to_i
          inspection_duration = 1
        end
      end
      calender_life_value   = nil
      calender_life_value   = 
        (row[Part::AIRCRAFT_PART_LIFE_CALENDER].present?) ? row[Part::AIRCRAFT_PART_LIFE_CALENDER].downcase.gsub("year",'').strip.to_i : 0
      total_hours  = (row[Part::AIRCRAFT_PART_LIFE_HOUR].present?) ? row[Part::AIRCRAFT_PART_LIFE_HOUR].downcase.gsub("hrs",'').strip.to_i : 0

      if row[Part::AIRCRAFT_PART_INSTALLED_DATE].present?
        if row[Part::AIRCRAFT_PART_INSTALLED_DATE].is_a? Date        
          installed_date      = DateTime.strptime(row[Part::AIRCRAFT_PART_INSTALLED_DATE].to_s, '%Y-%m-%d')
        else
          installed_date      = DateTime.strptime(row[Part::AIRCRAFT_PART_INSTALLED_DATE].to_s, '%m/%d/%Y')
        end
        if !installed_date.is_a? Date
          puts 'installed date is not a date'
        end
      end
      if row[Part::AIRCRAFT_PART_MANU_DATE].present?
        if row[Part::AIRCRAFT_PART_MANU_DATE].is_a? Date        
          manufacturing_date      = DateTime.strptime(row[Part::AIRCRAFT_PART_MANU_DATE].to_s, '%Y-%m-%d')
        else
          manufacturing_date      = DateTime.strptime(row[Part::AIRCRAFT_PART_MANU_DATE].to_s, '%m/%d/%Y')
        end
        if !manufacturing_date.is_a? Date
          puts 'manufacturing date is not a date'
        end
      end
      if manufacturing_date.present?
        track_from_cd = 1
      else
        track_from_cd = 0
      end
      install_hour        = row[Part::AIRCRAFT_PART_INSTALL_HOUR].to_f
      
      completed_hours     = (self.flight_hours.to_f - install_hour.to_f).round(2)
      landings_completed  = self.landings

      serial_no           = row[Part::AIRCRAFT_PART_SERIAL_NO]
      trade               = row[Part::AIRCRAFT_PART_TRADE].downcase
      number_serial_no = "#{number}-#{serial_no}"
      if serial_no.present?
        part = Part.where(number_serial_no: number_serial_no).first
      else
        part = Part.where(number: number).where(aircraft: aircraft).first
      end
      
      part_data = {            
            aircraft_id: self.id, 
            trade: trade, 
            track_from_cd: track_from_cd, 
            number: number, 
            serial_no: serial_no, 
            number_serial_no: number_serial_no, 
            description: description,                         
            is_lifed: is_lifed, 

            inspection_duration: inspection_duration, 
            inspection_hours: inspection_hours, 
            inspection_calender_value: inspection_calender_value,

            calender_life_value: calender_life_value,
            total_hours: total_hours,
                        
            completed_hours: completed_hours,
            installed_date: installed_date,
            manufacturing_date: manufacturing_date,
            landings_completed: landings_completed
          }            
      
      if part.present?
        part.update(part_data)
      else
        part = Part.create(part_data)
      end      
    end
  end

  def check_inspections
    scheduled_inspections.scheduled_insp.each do |scheduled_inspection|
      scheduled_inspection.update_scheduled_inspections self.flight_hours
    end
    scheduled_inspections.pending.each do |scheduled_inspection|
      scheduled_inspection.update_scheduled_inspections self.flight_hours
    end
    parts.each do |part|
      part.scheduled_inspections.scheduled_insp.each do |scheduled_inspection|
        scheduled_inspection.update_scheduled_inspections part.completed_hours  
      end
      part.scheduled_inspections.pending.each do |scheduled_inspection|
        scheduled_inspection.update_scheduled_inspections part.completed_hours  
      end
    end    
  end
end