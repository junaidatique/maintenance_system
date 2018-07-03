
#rake db:seed:scheduled_inspections
scheduled_inspections = ScheduledInspection.pending_n_due.all
scheduled_inspections.each do |scheduled_inspection|
  scheduled_inspection.started_by_id = User.where(role_cd: 1).first.id
  scheduled_inspection.inspection_started = Time.zone.now
  scheduled_inspection.status_cd = 2
  scheduled_inspection.save!
end

Techlog.where(type_cd: 2).where(condition_cd: 0).each do |t|
  t.condition_cd = 1
  t.verified_tools = true
  t.action = 'Done'
  t.save
end
Techlog.where(condition_cd: 2).each do |t|
  t.condition_cd = 1
  t.verified_tools = true
  t.action = 'Done'
  t.save
end
  