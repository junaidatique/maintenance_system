class Inspection
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  as_enum :kind, to_replace: 0, to_inspect: 1
  as_enum :type, aircraft: 0, part: 1
  as_enum :category, aircraft_timed: 1, aircraft_calender: 2
  as_enum :duration, day: 0, month: 1, year: 2
  
  field :name, type: String
  field :no_of_hours, type: Float
  field :calender_value, type: Integer  
  field :part_number, type: String
  field :is_repeating, type: Mongoid::Boolean, default: 1
  

  validate :part_number_presence
  

  def part_number_presence
    if type_cd == 1 and part_number.blank?
      errors.add(:part_number, " can't be blank")
    end
  end

  has_many :work_packages, dependent: :destroy
  has_many :scheduled_inspections, dependent: :destroy  

  scope :aircraft_inspection, -> { any_of({type_cd: 0}, {type_cd: 0.to_s})}
  scope :part_inspection, -> { any_of({type_cd: 1}, {type_cd: 1.to_s})}
  
  scope :to_be_replaced, -> { any_of({kind_cd: 0}, {kind_cd: 0.to_s})}
  scope :to_be_inspected, -> { any_of({kind_cd: 1}, {kind_cd: 1.to_s})}

  scope :aircraft_25_hour, -> { where(type_cd: 0).where(no_of_hours: 25) }
  scope :aircraft_50_hour, -> { where(type_cd: 0).where(no_of_hours: 50) }
  scope :aircraft_100_hour, -> { where(type_cd: 0).where(no_of_hours: 100) }
  scope :aircraft_400_hour, -> { where(type_cd: 0).where(no_of_hours: 400) }

  after_create :create_work_package

  def create_work_package
    if type_cd == 1 and self.part_number.present?
      
      part = Part.where(number: self.part_number).first
      autherization_code = AutherizationCode.where(code: 'BAEO01').first
      unless part.blank?
        WorkPackage.create!({
            inspection: self, 
            description: "#{part.description} Inspection", 
            autherization_code: autherization_code
          })
      end
    end
  end


  def create_aircraft_inspection aircraft, last_inspection_date = nil, last_inspection_hours = nil
    # if there is no incomplete inspction 
    if aircraft.scheduled_inspections.where(inspection_id: self.id).not_completed.count == 0
      sp = ScheduledInspection.new
      # if this is not the first ever inspection
      if aircraft.scheduled_inspections.where(inspection_id: self.id).completed.count > 0        
        sp.hours = 0
        if no_of_hours > 0
          sp.hours              = aircraft.flight_hours + no_of_hours.to_f
          sp.completed_hours    = aircraft.flight_hours
        end
      else # if inspection already created
        # don't create not repeating 
        if !is_repeating and aircraft.flight_hours > no_of_hours and no_of_hours > 0
          return
        end        
        sp.hours              = last_inspection_hours.to_f + no_of_hours.to_f
        sp.completed_hours    = aircraft.flight_hours
      end
      if last_inspection_date.present?
        sp.starting_date      = last_inspection_date
      else
        sp.starting_date      = Time.zone.now
      end
      
      sp.calender_life_date = self.get_duration sp.starting_date
      sp.is_repeating       = self.is_repeating
      sp.inspection         = self
      sp.status_cd          = 0
      sp.inspectable        = aircraft
      sp.save!  
      self.scheduled_inspections << sp
      sp.update_scheduled_inspections sp.completed_hours
    end    
  end
  
  def create_part_inspection part
    unless part.installed_date.blank?
      if self.no_of_hours > 0 and !self.is_repeating and part.completed_hours.present? and part.completed_hours > self.no_of_hours
        return;
      end
      if part.scheduled_inspections.where(inspection_id: self.id).not_completed.to_be_inspected.count == 0
        sp = ScheduledInspection.new
        if part.scheduled_inspections.where(inspection_id: self.id).count == 0                               
          h = 0
          if part.completed_hours.present? and no_of_hours > 0
            begin
              h              = h + no_of_hours.to_f                      
            end while part.completed_hours > h
          end
          sp.hours              = h
        else
          sp.starting_date      = Time.zone.now
          sp.calender_life_date = self.get_duration sp.starting_date        
          sp.hours              = 0
          if no_of_hours > 0
            sp.hours              = part.completed_hours + no_of_hours        
          end
        end                
      else
        sp = part.scheduled_inspections.where(inspection_id: self.id).not_completed.to_be_inspected.first        
        # sp.hours              = 0
        # if no_of_hours > 0
        #   sp.hours              = part.completed_hours + no_of_hours        
        # end
      end
      sp.starting_date      = part.installed_date        
      sp.calender_life_date = self.get_duration sp.starting_date        
      # if sp.calender_life_date.present? and sp.calender_life_date < Time.zone.now
      while sp.calender_life_date.present? and sp.calender_life_date < Time.zone.now do
        sp.calender_life_date = self.get_duration sp.calender_life_date
      end
      sp.completed_hours    = part.completed_hours
      sp.inspection         = self
      sp.is_repeating       = self.is_repeating
      sp.status_cd          = 0
      sp.trade_cd           = part.trade_cd
      sp.kind_cd            = self.kind_cd
      sp.inspectable        = part
      sp.save!
      self.scheduled_inspections << sp
      sp.update_scheduled_inspections part.completed_hours
    end
  end

  def create_part_repalcement part    
    if (part.installed_date.present? and part.calender_life_value > 0) or part.total_hours > 0
      if part.scheduled_inspections.where(inspection_id: self.id).not_completed.to_be_replaced.count == 0
        sp = ScheduledInspection.new
        if part.track_from_cd == 0
          sp.starting_date      = part.installed_date
        else
          sp.starting_date      = part.manufacturing_date
        end
        sp.calender_life_date = nil
        sp.calender_life_date = sp.starting_date + calender_value.years if calender_value.present? and calender_value > 0 and sp.starting_date.present?
        sp.hours              = no_of_hours        
        sp.completed_hours    = part.completed_hours
        sp.inspection         = self
        sp.is_repeating       = self.is_repeating
        sp.status_cd          = 0
        sp.trade_cd           = part.trade_cd
        sp.kind_cd            = self.kind_cd
        sp.inspectable        = part
        sp.save!
        self.scheduled_inspections << sp
        sp.update_scheduled_inspections part.completed_hours
      end
    end
  end

  

  

  def get_duration starting_date
    calender_life_date = nil
    if calender_value.present? and calender_value > 0
      if self.duration_cd == 0
        calender_life_date = starting_date + calender_value.days
      elsif self.duration_cd == 1
        calender_life_date = starting_date + calender_value.months
      elsif self.duration_cd == 2
        calender_life_date = starting_date + calender_value.years
      end
    end
    calender_life_date
  end

  
end
