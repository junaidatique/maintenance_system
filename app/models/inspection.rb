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
end