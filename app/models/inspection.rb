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
 
  after_create :create_inspections

  scope :aircraft_inspection, -> { any_of({type_cd: 0}, {type_cd: 0.to_s})}
  scope :part_inspection, -> { any_of({type_cd: 1}, {type_cd: 1.to_s})}
  
  scope :to_be_replaced, -> { any_of({kind_cd: 0}, {kind_cd: 0.to_s})}
  scope :to_be_inspected, -> { any_of({kind_cd: 1}, {kind_cd: 1.to_s})}

  def create_aircraft_inspection aircraft
    if aircraft.scheduled_inspections.where(inspection_id: self.id).not_completed.count == 0
      sp = ScheduledInspection.new
      if aircraft.scheduled_inspections.where(inspection_id: self.id).completed.count > 0        
        sp.hours = 0
        if no_of_hours > 0
          sp.hours              = aircraft.flight_hours + no_of_hours.to_f
          sp.completed_hours    = aircraft.flight_hours
        end
      else
        if !is_repeating and aircraft.flight_hours > no_of_hours and no_of_hours > 0
          return
        end
        h = 0
        if no_of_hours > 0 and (aircraft.flight_hours < no_of_hours or category_cd == 1)
          begin
            h              = h + no_of_hours.to_f
          end while aircraft.flight_hours > h
        end
        sp.hours              = h
        sp.completed_hours    = aircraft.flight_hours
      end
      
      sp.starting_date      = Time.zone.now        
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
      if part.scheduled_inspections.where(inspection_id: self.id).not_completed.count == 0
        sp = ScheduledInspection.new
        if part.scheduled_inspections.where(inspection_id: self.id).count == 0           
          if self.no_of_hours > 0 and !self.is_repeating and part.completed_hours > self.no_of_hours            
            return;          
          end           
          sp.starting_date      = part.installed_date        
          h = 0
          if no_of_hours > 0
            begin
              h              = h + no_of_hours.to_f                      
            end while part.completed_hours > h
          end
          sp.hours              = h
        else
          sp.starting_date      = Time.zone.now
          sp.hours              = 0
          if no_of_hours > 0
            sp.hours              = part.completed_hours + no_of_hours        
          end
        end        
        sp.calender_life_date = self.get_duration sp.starting_date        
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

  def create_part_repalcement part    
    if (part.installed_date.present? and part.calender_life_value > 0) or part.total_hours > 0
      if part.scheduled_inspections.where(inspection_id: self.id).not_completed.count == 0
        sp = ScheduledInspection.new
        sp.starting_date      = part.installed_date
        sp.calender_life_date = nil
        sp.calender_life_date = part.installed_date + calender_value.years if calender_value.present? and calender_value > 0
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

  def create_inspections
    if (type_cd.to_i == 0)
      aircrafts = Aircraft.all
      aircrafts.each do |aircraft| 
        self.create_aircraft_inspection aircraft
      end
    elsif (type_cd.to_i == 1)
      # parts = Part.where(number: part_number)
      # parts.each do |inspection_item|         
      # end
    end    
    WorkPackage.create!({description: 'Test', work_unit_code_id: WorkUnitCode.last.id, inspection_id: self.id})
  end

  

  def get_duration starting_date
    calender_life_date = nil
    if calender_value.present?
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

  # def update_scheduled_inspections aircraft_id, hours
  #   self.scheduled_inspections.not_completed.where(inspectable_id: aircraft_id).gt(hours: 0).update_all({completed_hours: hours})   
  #   self.scheduled_inspections.not_completed.where(inspectable_id: Aircraft.find(aircraft_id).parts.map{|p|} p.id).gt(hours: 0).update_all({completed_hours: hours})   
  #   pending_schedules = ScheduledInspection.collection.aggregate([
  #     { 
  #       "$project" => 
  #       {
  #         "diff" => { 
  #           "$subtract" => [ "$hours", "$completed_hours" ] 
  #         }          
  #       }
  #     },
  #     {
  #       "$match"=>{"diff"=>{"$lt"=>10,"$gt"=>0}}
  #     }
  #   ])
  #   ScheduledInspection.in(id: pending_schedules.map{|sch| sch['_id']}).scheduled_insp.update_all({status_cd: 1})
  #   due_schedules = ScheduledInspection.collection.aggregate([
  #     { 
  #       "$project" => 
  #       {
  #         "diff" => { 
  #           "$subtract" => [ "$hours", "$completed_hours" ] 
  #         },
  #         "hours" => 1,
  #       }
  #     },
  #     {
  #       "$match"=>{"diff"=>{"$lte"=>0}, "hours" => {"$gt" => 0} }
  #     }
  #   ])
  #   ScheduledInspection.in(id: due_schedules.map{|sch| sch['_id']}).not_completed.update_all({status_cd: 4})
  # end
end
