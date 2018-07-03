class Inspection
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

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

  def create_aircraft_inspection aircraft
    if aircraft.scheduled_inspections.where(inspection_id: self.id).not_completed.count == 0
      sp = ScheduledInspection.new        
      sp.hours              = aircraft.flight_hours + no_of_hours.to_f
      sp.completed_hours    = aircraft.flight_hours
      sp.starting_date      = Time.zone.now        
      sp.calender_life_date = self.get_duration sp.starting_date
      sp.inspection         = self
      sp.status_cd          = 0
      sp.inspectable        = aircraft
      sp.save!  
      self.scheduled_inspections << sp
    end    
  end
  
  def create_part_inspection part
    unless part.installed_date.blank?
      if part.scheduled_inspections.where(inspection_id: self.id).not_completed.count == 0
        sp = ScheduledInspection.new
        if part.scheduled_inspections.where(inspection_id: self.id).count == 0  
          sp.starting_date      = part.installed_date        
        else
          sp.starting_date      = Time.zone.now
        end        
        sp.calender_life_date = self.get_duration sp.starting_date
        sp.hours              = part.completed_hours + no_of_hours        
        sp.completed_hours    = part.completed_hours
        sp.inspection         = self
        sp.status_cd          = 0
        sp.inspectable        = part
        sp.save!
        self.scheduled_inspections << sp
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
      parts = Part.where(number: part_number)
      parts.each do |inspection_item| 
        
      end
    end    
  end

  

  def get_duration starting_date
    if self.duration_cd == 0
      calender_life_date = starting_date + calender_value.days
    elsif self.duration_cd == 1
      calender_life_date = starting_date + calender_value.months
    elsif self.duration_cd == 2
      calender_life_date = starting_date + calender_value.years
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
