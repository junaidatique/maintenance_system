class ScheduledInspection
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid
  
  as_enum :status, Scheduled: 0, Pending: 1, "In progress": 2, Completed: 3, Due: 4
  as_enum :condition, normal: 0, extention_applied: 1, extention_granted: 2

  field :hours, type: Float, default: 0
  field :completed_hours, type: Float, default: 0
  field :calender_life_date, type: Date
  field :starting_date, type: Date
  field :inspection_started, type: Date
  field :inspection_completed, type: Date
  field :is_repeating, type: Mongoid::Boolean
  field :trade_cd, type: Integer
  field :kind_cd, type: Integer
  field :extention_hours, type: Integer
  field :extention_days, type: Integer
  
  belongs_to :inspection  
  belongs_to :started_by, :class_name => "User", optional: true
  belongs_to :inspectable, polymorphic: true

  has_one :techlog

  scope :scheduled_insp, -> { where(status_cd: 0)}
  scope :not_completed, -> { ne(status_cd: 3)}
  scope :in_progress, -> { where(status_cd: 2)}
  scope :completed, -> { where(status_cd: 3)}
  scope :due, -> { where(status_cd: 4)}
  scope :pending, -> { where(status_cd: 1)}
  scope :pending_n_due, -> { any_of({status_cd: 1}, {status_cd: 4})}
  scope :calender_based, -> { ne(calender_life_date: nil)}
  
  validate :check_extention

  def check_extention
    if condition_cd == 1
      if extention_hours == 0 and extention_days == 0
        errors.add(:extention_hours, " Please select at least one option.")
      end
      if extention_days > 0 and self.calender_life_date.blank?
        errors.add(:extention_days, " This inspection is not based on days.")
      end
      if extention_hours > 0 and self.hours == 0
        errors.add(:extention_hours, " This inspection is not based on hours.")
      end
    end
  end

  before_create :set_normal
  after_update :start_work_package

  def set_normal
    self.condition_cd = 0    
  end

  def start_work_package    
    if (status_cd_was == 0 or status_cd_was == 1 or status_cd_was == 4) and status_cd == 2         
      if inspectable_type == Aircraft.name
        inspectable_name = inspectable.tail_number
        aircraft_id = inspectable.id
      else
        inspectable_name = inspectable.number        
        aircraft_id = inspectable.aircraft_id
      end
      parent_log = Techlog.create!({type_cd: 2, condition_cd: 2, log_time: "#{Time.zone.now.strftime("%H:%M %p")}", 
        description: "#{self.inspection.name} for #{inspectable_name}", 
        action: "#{self.inspection.name} for #{inspectable_name}", 
        user_id: self.started_by_id, log_date: "#{Time.zone.now.strftime("%Y-%m-%d")}", 
        aircraft_id: aircraft_id, dms_version: System.first.settings['dms_version_number'],
        scheduled_inspection_id: self.id
      })      
      self.inspection.work_packages.each do |work_package|        
        log = Techlog.create!({type_cd: 2, condition_cd: 0, 
          log_time: "#{Time.zone.now.strftime("%H:%M %p")}",
          description: work_package.description, work_unit_code: work_package.work_unit_code.id, 
          user_id: self.started_by_id, log_date: "#{Time.zone.now.strftime("%Y-%m-%d")}", 
          aircraft_id: aircraft_id, dms_version: System.first.settings['dms_version_number'],
          parent_techlog_id: parent_log.id
        })
      end
    end
    if condition_cd_was == 0 and condition_cd == 1
      log = Techlog.create!({type_cd: 2, condition_cd: 0, 
          log_time: "#{Time.zone.now.strftime("%H:%M %p")}",
          description: "Extention Applied for #{self.inspection.name}", 
          user_id: self.started_by_id, log_date: "#{Time.zone.now.strftime("%Y-%m-%d")}", 
          aircraft_id: aircraft_id, dms_version: System.first.settings['dms_version_number'], 
          is_extention_applied: true
        })
    end    
  end
  def complete_inspection
    self.status_cd = 3
    self.inspection_completed = Time.zone.now
    self.save
    if inspectable_type == Aircraft.name
      if self.inspection.is_repeating
        self.inspection.create_aircraft_inspection Aircraft.find inspectable_id
      end
    else
      if self.inspection.is_repeating
        self.inspection.create_part_inspection Part.find inspectable_id      
      end
    end
  end

  def update_scheduled_inspections completed_hours
    self.completed_hours = completed_hours
    if hours > 0 and self.completed_hours.present?
      if (self.hours - self.completed_hours) <= 0
        self.status = 4
      elsif (self.hours - self.completed_hours) < 10
        self.status = 1
      end
    end
    if calender_life_date.present?
      if calender_life_date < (Time.zone.now + 30.days)
        self.status_cd = 1 if self.status_cd != 4
      end
      if calender_life_date < (Time.zone.now)
        self.status_cd = 4    
      end
    end    
    self.save
  end
  
end
