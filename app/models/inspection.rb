class Inspection
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :no_of_hours, type: Float
  field :calender_value, type: Integer
  field :calender_unit, type: String

  has_many :work_packages
  has_many :scheduled_inspections

  belongs_to :part, optional: true
  belongs_to :aircraft, optional: true

  after_create :create_scheduled_inspection

  def create_scheduled_inspection
    sp = ScheduledInspection.new
    if aircraft.present?      
      sp.hours = aircraft.flight_hours + no_of_hours
      starting_date = Time.now
    else 
      sp.hours = part.completed_hours + no_of_hours
      starting_date = part.installed_date
    end
    if calender_unit == 'day'
      sp.calender_life_date = starting_date + calender_value.days
    elsif calender_unit == 'month'
      sp.calender_life_date = starting_date + calender_value.months
    elsif calender_unit == 'year'
      sp.calender_life_date = starting_date + calender_value.years
    end
    sp.inspection = self
    sp.status_cd = 0
    sp.save!  
    self.scheduled_inspections << sp
  end

  def update_scheduled_inspections hours
    self.scheduled_inspections.gt(hours: 0).update_all({completed_hours: hours})   
    pending_schedules = ScheduledInspection.collection.aggregate([
      { 
        "$project" => 
        {
          "diff" => { 
            "$subtract" => [ "$hours", "$completed_hours" ] 
          }          
        }
      },
      {
        "$match"=>{"diff"=>{"$lt"=>10,"$gt"=>0}}
      }
    ])
    ScheduledInspection.in(id: pending_schedules.map{|sch| sch['_id']}).update_all({status_cd: 1})
  end
end
