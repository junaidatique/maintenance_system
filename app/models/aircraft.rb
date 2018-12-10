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
  has_many :part_items, dependent: :destroy
  has_many :part_histories, dependent: :destroy
  has_many :flying_histories, dependent: :destroy
  has_many :landing_histories, dependent: :destroy
  has_many :scheduled_inspections, as: :inspectable

  accepts_nested_attributes_for :part_items, :allow_destroy => true  
    
  def update_part_values flying_log
    self.flight_hours = flying_log.aircraft_total_time.corrected_total_aircraft_hours.to_f
    self.landings     = flying_log.aircraft_total_time.corrected_total_landings.to_f
    self.engine_hours = flying_log.aircraft_total_time.corrected_total_engine_hours.to_f
    self.prop_hours   = flying_log.aircraft_total_time.corrected_total_prop_hours.to_f
    self.save
    self.scheduled_inspections.not_completed.each do |scheduled_inspection|
      scheduled_inspection.update_scheduled_inspections self.flight_hours      
    end
    lifed_parts = self.part_items.lifed    
    lifed_parts.each do |part|            
      part.create_history_with_flying_log flying_log
    end    
    tyre_parts = self.part_items.tyre
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
    (4..xlsx.last_row).each do |i|
      row               = xlsx.row(i)      
      aircraft          = self
      # puts row.inspect
      # puts row[Part::AIRCRAFT_PART_LAST_HOUR_INSP].inspect
      # puts row[Part::AIRCRAFT_PART_LANDINGS].inspect
      # next;
      number     = row[Part::AIRCRAFT_PART_NUMBER].to_s.gsub("\n", '')
      noun       = row[Part::AIRCRAFT_PART_NOUN]
      trade      = row[Part::AIRCRAFT_PART_TRADE].downcase
      # formulate inspection 
      inspection_hours  = (row[Part::AIRCRAFT_PART_INSP_HOUR].present?) ? row[Part::AIRCRAFT_PART_INSP_HOUR].downcase.gsub("hrs",'').strip.to_i : nil
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

      # formulate life
      lifed_calender_value   = nil
      if row[Part::AIRCRAFT_PART_LIFE_CALENDER].present?
        if row[Part::AIRCRAFT_PART_LIFE_CALENDER].downcase.count('y') > 0
          lifed_calender_value = row[Part::AIRCRAFT_PART_LIFE_CALENDER].downcase.gsub("year",'').strip.to_i
          lifed_duration = 2
        else
          lifed_calender_value = row[Part::AIRCRAFT_PART_LIFE_CALENDER].downcase.gsub("month",'').strip.to_i
          lifed_duration = 1
        end
      end      
      lifed_hours  = (row[Part::AIRCRAFT_PART_LIFE_HOUR].present?) ? row[Part::AIRCRAFT_PART_LIFE_HOUR].downcase.gsub("hrs",'').strip.to_f : 0

      # manufactoring or installing date 
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
        track_from = :manufacturing_date
      elsif installed_date.present?
        track_from = :installation_date
      else
        track_from = :no_track
      end

      
            
      landings_completed  = nil
      if row[Part::AIRCRAFT_PART_LANDINGS].present?
        landings_completed  = row[Part::AIRCRAFT_PART_LANDINGS].to_i
      end

      serial_no           = row[Part::AIRCRAFT_PART_SERIAL_NO]
      last_inspection_date = nil
      if row[Part::AIRCRAFT_PART_LAST_CALANDER_INSP].present?        
        if row[Part::AIRCRAFT_PART_LAST_CALANDER_INSP].is_a? Date        
          last_inspection_date = DateTime.strptime(row[Part::AIRCRAFT_PART_LAST_CALANDER_INSP].to_s, '%Y-%m-%d')
        else
          puts row[Part::AIRCRAFT_PART_LAST_CALANDER_INSP].inspect
          last_inspection_date = DateTime.strptime(row[Part::AIRCRAFT_PART_LAST_CALANDER_INSP].to_s, '%m/%d/%Y')
        end
        if !last_inspection_date.is_a? Date
          puts 'installed date is not a date'
        end
      end
      completed_hours_when_installed = nil      
      completed_hours_when_installed = (row[Part::AIRCRAFT_PART_COMP_HOURS].present?) ? row[Part::AIRCRAFT_PART_COMP_HOURS].to_s.downcase.gsub("hrs",'').strip.to_f : 0

      aircraft_installation_hours = 0
      remaining_hours     = 
      install_hour = (row[Part::AIRCRAFT_PART_INSTALL_HOUR].present?) ? row[Part::AIRCRAFT_PART_INSTALL_HOUR].to_s.downcase.gsub("hrs",'').strip.to_f : 0
      
      completed_hours     = ((self.flight_hours.to_f - install_hour.to_f) + completed_hours_when_installed.to_f).round(2)
      aircraft_installation_hours = install_hour.to_f

      
      # if install_hour.present? and install_hour > 0
        
      # else
      #   completed_hours     = (self.flight_hours.to_f).round(2)
      # end

      
      
      part = Part.where(number: number).first
      if part.blank?
        part_data = {                        
          trade: trade,             
          number: number,                         
          noun: noun,                                     
          track_from: track_from,                                     

          inspection_duration: inspection_duration, 
          inspection_hours: inspection_hours, 
          inspection_calender_value: inspection_calender_value,

          lifed_duration: lifed_duration,
          lifed_calender_value: lifed_calender_value,
          lifed_hours: lifed_hours,
        }   
        part = Part.create!(part_data)
      end

      if number == 'ENPL-RT10227' 
        category = :engine
      elsif number == 'HC-C2YK-1BF I/L C2K00180'
        category = :propeller
      elsif noun == 'MAIN WHEEL LT'
        category = :left_tyre
      elsif noun == 'MAIN WHEEL RT'
        category = :right_tyre
      elsif noun == 'NOSE WHEEL'
        category = :nose_tail
      elsif number == '6127279-067'
        category = :battery
      end

      part_item_data = {
        part_id: part.id,
        aircraft_id: self.id,             
        serial_no: serial_no, 
        completed_hours: completed_hours,
        installed_date: installed_date,
        manufacturing_date: manufacturing_date,
        landings_completed: landings_completed,
        quantity: 1,        
        last_inspection_date: last_inspection_date,        
        aircraft_installation_hours: aircraft_installation_hours,
        completed_hours_when_installed: completed_hours_when_installed,
        category: category
      }            
      if serial_no.present?
        part_item = PartItem.where(part_id: part.id).where(serial_no: serial_no).first
      else
        part_item = PartItem.where(part_id: part.id).where(aircraft: aircraft).first
      end
      if part_item.present?
        part_item.update(part_item_data)
      else
        part_item = PartItem.create(part_item_data)
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
    part_items.each do |part|
      part.scheduled_inspections.scheduled_insp.each do |scheduled_inspection|
        scheduled_inspection.update_scheduled_inspections part.completed_hours  
      end
      part.scheduled_inspections.pending.each do |scheduled_inspection|
        scheduled_inspection.update_scheduled_inspections part.completed_hours  
      end
    end    
  end
end