
#rails db:seed:aircraft_fix

aircraft = Aircraft.where(tail_number: 'QA307').first
aircraft.flying_logs.order(created_at: :asc).each do |flying_log| 
  puts flying_log.created_at
  puts flying_log.aircraft_total_time.carried_over_aircraft_hours

  previous_flying_log = aircraft.flying_logs.lt(id: flying_log.id).order(created_at: :desc).first  
  if (previous_flying_log.blank?) 
    carried_over_aircraft_hours = flying_log.aircraft_total_time.carried_over_aircraft_hours
    carried_over_engine_hours   = flying_log.aircraft_total_time.carried_over_engine_hours
    carried_over_landings       = flying_log.aircraft_total_time.carried_over_landings
    carried_over_prop_hours     = flying_log.aircraft_total_time.carried_over_prop_hours
  else
    puts previous_flying_log.created_at
    carried_over_aircraft_hours = previous_flying_log.aircraft_total_time.corrected_total_aircraft_hours
    carried_over_engine_hours   = previous_flying_log.aircraft_total_time.corrected_total_engine_hours
    carried_over_landings       = previous_flying_log.aircraft_total_time.corrected_total_landings
    carried_over_prop_hours     = previous_flying_log.aircraft_total_time.corrected_total_prop_hours
  end
  flying_log.aircraft_total_time.carried_over_aircraft_hours   = carried_over_aircraft_hours.round(2)
  flying_log.aircraft_total_time.carried_over_engine_hours     = carried_over_engine_hours.round(2)
  flying_log.aircraft_total_time.carried_over_landings         = carried_over_landings.round(2)
  flying_log.aircraft_total_time.carried_over_prop_hours       = carried_over_prop_hours.round(2)

  flying_log.save
  flying_log = FlyingLog.find(flying_log.id)
  sortie = flying_log.sortie
  if sortie.blank?
    flight_time    = 0
    total_landings = 0
  else     
    flight_time    = sortie.calculate_flight_time
    total_landings = sortie.calculate_landings
  end
  

  f_total = flying_log.aircraft_total_time
  f_total.this_sortie_aircraft_hours = flight_time.to_f.round(2)
  f_total.this_sortie_landings       = total_landings
  f_total.this_sortie_engine_hours   = flight_time.to_f.round(2)
  f_total.this_sortie_prop_hours     = flight_time.to_f.round(2)

  t_landings            = f_total.carried_over_landings.to_i + total_landings.to_i
  total_aircraft_hours  = f_total.carried_over_aircraft_hours.to_f + flight_time.to_f.round(2)
  total_engine_hours    = f_total.carried_over_engine_hours.to_f + flight_time.to_f.round(2)
  total_prop_hours      = f_total.carried_over_prop_hours.to_f + flight_time.to_f.round(2)

  f_total.new_total_landings        = t_landings
  f_total.new_total_aircraft_hours  = total_aircraft_hours.round(2)
  f_total.new_total_engine_hours    = total_engine_hours.round(2)
  f_total.new_total_prop_hours      = total_prop_hours.round(2)

  f_total.corrected_total_engine_hours     = total_engine_hours.round(2)
  f_total.corrected_total_aircraft_hours   = total_aircraft_hours.round(2)
  f_total.corrected_total_landings         = t_landings
  f_total.corrected_total_prop_hours       = total_prop_hours.round(2)

  flying_log.save
  flying_log.create_history

end
flying_log = aircraft.flying_logs.last
aircraft.flight_hours = flying_log.aircraft_total_time.corrected_total_aircraft_hours.to_f
aircraft.landings     = flying_log.aircraft_total_time.corrected_total_landings.to_f
aircraft.engine_hours = flying_log.aircraft_total_time.corrected_total_engine_hours.to_f
aircraft.prop_hours   = flying_log.aircraft_total_time.corrected_total_prop_hours.to_f
aircraft.save
# aircraft.part_items.each do |part|
#   part.part_histories.where(flying_log_id: nil).where(hours: -0.2).each do |part_history|  
#     part_history.hours = 9.8
#     part_history.save
#   end
#   part.part_histories.where(flying_log_id: nil).where(hours: 40.8).each do |part_history|  
#     part_history.hours = 50.8
#     part_history.save
#   end
# end

# flight_hours = 50.8
# engine_hours = 9.8
# aircraft.flying_logs.completed.order(number: :asc).each do |f|
#   next if f.flightline_servicing.inspection_performed_cd == 2
#   aircraft_total_time = f.aircraft_total_time  
#   aircraft_total_time.carried_over_engine_hours     = engine_hours
#   aircraft_total_time.carried_over_aircraft_hours   = flight_hours  
#   aircraft_total_time.carried_over_prop_hours       = engine_hours
#   aircraft_total_time.save
#   f.update_aircraft_times
#   f.save  
#   engine_hours = f.aircraft_total_time.corrected_total_engine_hours
#   flight_hours = f.aircraft_total_time.corrected_total_aircraft_hours  
# end
# s = ScheduledInspection.find('5b8785d9b90faf078fbe1639')
# s.destroy
# s = ScheduledInspection.find('5b8785d8b90faf078fbe1624')
# s.destroy
# # f = aircraft.flying_logs.completed.first
# # f.update_aircraft_times
# # f.save
