
#rails db:seed:aircraft_fix
aircraft = Aircraft.where(tail_number: 'QA306').first
aircraft.parts.each do |part|
  part.part_histories.where(flying_log_id: nil).where(hours: -0.2).each do |part_history|  
    part_history.hours = 9.8
    part_history.save
  end
  part.part_histories.where(flying_log_id: nil).where(hours: 40.8).each do |part_history|  
    part_history.hours = 50.8
    part_history.save
  end
end

flight_hours = 50.8
engine_hours = 9.8
aircraft.flying_logs.completed.order(number: :asc).each do |f|
  next if f.flightline_servicing.inspection_performed_cd == 2
  aircraft_total_time = f.aircraft_total_time  
  aircraft_total_time.carried_over_engine_hours     = engine_hours
  aircraft_total_time.carried_over_aircraft_hours   = flight_hours  
  aircraft_total_time.carried_over_prop_hours       = engine_hours
  aircraft_total_time.save
  f.update_aircraft_times
  f.save  
  engine_hours = f.aircraft_total_time.corrected_total_engine_hours
  flight_hours = f.aircraft_total_time.corrected_total_aircraft_hours  
end
s = ScheduledInspection.find('5b8785d9b90faf078fbe1639')
s.destroy
s = ScheduledInspection.find('5b8785d8b90faf078fbe1624')
s.destroy
# f = aircraft.flying_logs.completed.first
# f.update_aircraft_times
# f.save
