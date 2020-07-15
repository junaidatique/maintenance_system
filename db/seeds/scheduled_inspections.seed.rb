
#rails db:seed:scheduled_inspections
# scheduled_inspections = ScheduledInspection.due.all
# scheduled_inspections.each do |scheduled_inspection|
#   scheduled_inspection.started_by_id = User.where(role_cd: 1).first.id
#   scheduled_inspection.inspection_started = Time.zone.now
#   scheduled_inspection.status_cd = 2
#   scheduled_inspection.save!
# end

# Techlog.where(type_cd: 2).where(condition_cd: 0).each do |t|
#   t.condition_cd = 1
#   t.verified_tools = true
#   t.action = 'Done'
#   t.save
# end
# Techlog.where(condition_cd: 2).each do |t|
#   t.condition_cd = 1
#   t.verified_tools = true
#   t.action = 'Done'
#   t.save
# end
  inspection = Inspection.find('5c2c6df3b90faf266333aa6c')
  inspection.duration_cd = 1
  inspection.no_of_hours = 50
  inspection.calender_value = 6
  inspection.save
  
  inspection = Inspection.find('5c2c6df3b90faf266333aa6d')
  inspection.duration_cd = 2
  inspection.no_of_hours = 100
  inspection.calender_value = 1
  inspection.save
  
  inspection = Inspection.find('5c2c6df3b90faf266333aa6e')  
  inspection.no_of_hours = 400  
  inspection.save
  
  inspection = Inspection.find('5c2c6df3b90faf266333aa6f')  
  inspection.duration_cd = 1
  inspection.no_of_hours = 0
  inspection.calender_value = 4
  inspection.save
  
  inspection = Inspection.find('5c2c6df3b90faf266333aa70')  
  inspection.duration_cd = 0
  inspection.no_of_hours = 0
  inspection.calender_value = 7
  inspection.save
  
  inspection = Inspection.find('5c2c6df3b90faf266333aa71')  
  inspection.duration_cd = 2
  inspection.no_of_hours = 0
  inspection.calender_value = 1
  inspection.save
  
  inspection = Inspection.find('5c2c6df3b90faf266333aa72')  
  inspection.duration_cd = 1
  inspection.no_of_hours = 0
  inspection.calender_value = 1
  inspection.save