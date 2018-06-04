class ScheduledInspection
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid
  
  as_enum :status, Scheduled: 0, Pending: 1, "In progress": 2, Completed: 3

  field :hours, type: Float, default: 0
  field :completed_hours, type: Float, default: 0
  field :calender_life_date, type: Date
  field :starting_date, type: Date
  field :inspection_started, type: Date
  field :inspection_completed, type: Date
  
  belongs_to :inspection  
  belongs_to :started_by, :class_name => "User", optional: true
  belongs_to :inspectable, polymorphic: true

  has_one :techlog

  scope :scheduled_insp, -> { where(status_cd: 0)}
  scope :not_completed, -> { ne(status_cd: 3)}
  scope :pending, -> { where(status_cd: 1)}
  
  after_update :start_work_package

  def start_work_package
    
    if (status_cd_was == 0 or status_cd_was == 1) and status_cd == 2      
      if inspectable_type == Aircraft.name
        inspectable_name = inspectable.tail_number
        aircraft_id = inspectable.id
      else
        inspectable_name = inspectable.number
        aircraft_id = nil
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
  end
  def complete_inspection
    self.status_cd = 3
    self.save
    if inspectable_type == Aircraft.name
      self.inspection.create_aircraft_inspection Aircraft.find inspectable_id
    end
  end
  
end
