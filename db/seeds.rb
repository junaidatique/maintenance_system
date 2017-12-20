cur_time  = Time.now
System.create! settings: {dms_version_number: 0.0}
puts 'Creating Aircraft'
aircraft_300  = Aircraft.create! number: '300', tail_number: 'QA300', serial_no: '#300', fuel_capacity: '50', oil_capacity: '50', flight_hours: 0, engine_hours: 0, landings: 0, prop_hours: 0


aircraft_301  = Aircraft.create! number: '301', tail_number: 'QA301', serial_no: '#301', fuel_capacity: '50', oil_capacity: '50', flight_hours: 0, engine_hours: 0, landings: 0, prop_hours: 0

aircraft_302  = Aircraft.create! number: '302', tail_number: 'QA302', serial_no: '#302', fuel_capacity: '50', oil_capacity: '50', flight_hours: 0, engine_hours: 0, landings: 0, prop_hours: 0

aircraft_303  = Aircraft.create! number: '303', tail_number: 'QA303', serial_no: '#303', fuel_capacity: '50', oil_capacity: '50', flight_hours: 0, engine_hours: 0, landings: 0, prop_hours: 0

Aircraft.each do |aircraft|
  for i in 1..16
    calender_life = ''
    installed_date = (cur_time).strftime("%Y-%m-%d")
    total_hours = 0
    total_landings = 0
    is_lifed = false
    if i == 5 or i == 6 or i == 7 or i == 8
      is_lifed = true
      calender_life = (cur_time + (60*60*24*365)).strftime("%Y-%m-%d")
    elsif i == 9 or i == 10 or i == 11 or i == 12
      is_lifed = true
      total_hours = 400
    elsif i == 13 or i == 14 or i == 15 or i == 16
      is_lifed = true
      total_landings = 200
    end
    Part.create({
      aircraft: aircraft, number: "#{Faker::Number.number(8)}-#{Faker::Number.number(4)}", 
      serial_no: "#{Faker::Number.number(5)}", 
      quantity: rand(10) + 1, 
      description: Faker::Lorem.words(1 + rand(4)).join(" "), 
      is_lifed: is_lifed, calender_life: calender_life, installed_date: installed_date, 
      total_part_hours: total_hours, total_landings: total_landings })
  end
end

puts 'Aircraft Created'
puts 'Creating FlyingPlan'
(0..10).each do |day|
  is_flying = 1 #Faker::Boolean.boolean
  aircraft_ids = []
  reason = ''
  if (is_flying)
    aircraft_ids = Aircraft.limit(1+rand(Aircraft.count)).sort_by{rand}.map{|aircraft| aircraft.id.to_s}
  else
    reason = Faker::Lorem.sentence(3)
  end
  # FlyingPlan.create! flying_date: day.business_days.ago.strftime("%Y-%m-%d"), is_flying: is_flying, aircraft_ids: aircraft_ids, reason: reason
  FlyingPlan.create! flying_date: (Time.now - day.days).strftime("%Y-%m-%d"), is_flying: is_flying, aircraft_ids: aircraft_ids, reason: reason
  print '.'
end
puts ''
puts 'FlyingPlan Created'

puts 'Creating Users'
User.roles.each do |role_name, role_key|
  User.create! username: role_name, name: role_name.to_s.sub('_',' '), 
                 role: role_name, password: '12345678', status: 1, personal_code: Faker::Number.number(6), rank: Faker::Lorem.word
  print '.'
end
puts ''
puts 'Users Created'

puts 'Creating WorkUnitCodes'
WorkUnitCode.wuc_types.each do |work_unit_code,code_key|
  w_code = WorkUnitCode.create code: work_unit_code.downcase, description: work_unit_code.to_s.sub('_',' ')
  print '.'
  # , "electrical", "radio", "instrument", "airframe", "engine"
  ["crew_cheif"].each do |role_name, role_key|
      WorkUnitCode.create code: "#{work_unit_code.downcase}_#{role_name.downcase}", description: "#{work_unit_code.to_s.sub('_',' ')} #{role_name.to_s.sub('_',' ')}", parent_id: w_code, wuc_type_cd: code_key
  end
end
puts ''
puts 'WorkUnitCodes Created'
# return
##################################################################
#sleep(2)
puts 'Creating Pre flight Flying Log'
flying_log = FlyingLog.new
last_flying_log = FlyingLog.last
if last_flying_log.present?
  flying_log.number = last_flying_log.number + 1
else
  flying_log.number = 1001
end
cur_time  = Time.now

flying_log.log_date = Time.now.strftime("%Y-%m-%d")
flying_log.aircraft = Aircraft.active.available.first
flying_log.location_from = Faker::Lorem.word
flying_log.location_to = Faker::Lorem.word

flying_log.build_ac_configuration
flying_log.ac_configuration.clean = 1
flying_log.ac_configuration.smoke_pods = 1
flying_log.ac_configuration.third_seat = 1
flying_log.ac_configuration.cockpit_cd = 1 #+ rand(2)

flying_log.build_flightline_servicing
flying_log.flightline_servicing.user = User.where(role_cd: 7).first
flying_log.flightline_servicing.inspection_performed = 0

flying_log.flightline_servicing.flight_start_time = cur_time.strftime("%H:%M %p")
flying_log.flightline_servicing.flight_end_time   = (cur_time + (10*60)).strftime("%H:%M %p")
flying_log.flightline_servicing.hyd = Faker::Lorem.word

flying_log.save
flying_log.flightline_service

puts 'Flighline serviced'

flying_log.fuel_refill = 1 + rand(flying_log.aircraft.fuel_capacity)
flying_log.oil_serviced = 1 + rand(flying_log.aircraft.oil_capacity)
flying_log.update_fuel
flying_log.save
flying_log.fill_fuel


flying_log.techlogs.where(type_cd: 0).each do |techlog|
  techlog.action = Faker::Lorem.sentence
  techlog.is_completed = true
  techlog.save
end
puts 'techlog finished'
flying_log.build_flightline_release
flying_log.flightline_release.flight_time = cur_time.strftime("%H:%M %p")
flying_log.flightline_release.user = User.where(role_cd: 7).first
flying_log.flight_release
flying_log.save
puts 'build_flightline_released'
flying_log.build_capt_acceptance_certificate
flying_log.capt_acceptance_certificate.flight_time = cur_time.strftime("%H:%M %p")
flying_log.capt_acceptance_certificate.view_history = 1
flying_log.capt_acceptance_certificate.mission_cd = 'mission_1'
flying_log.capt_acceptance_certificate.user = User.where(role_cd: 8).first
flying_log.book_flight
flying_log.save
puts 'book out completed'
#return
flying_log.build_sortie
flying_log.sortie.user = User.where(role_cd: 8).first
if flying_log.ac_configuration.cockpit_cd == 2
  flying_log.sortie.second_pilot = User.where(role_cd: 13).first
end
flying_log.sortie.third_seat_name = Faker::Lorem.word
flying_log.sortie.takeoff_time = (cur_time - (10*60)).strftime("%H:%M %p")
flying_log.sortie.landing_time = (cur_time + (10*60)).strftime("%H:%M %p")
flying_log.sortie.pilot_comment = 'Un_satisfactory'
flying_log.sortie.touch_go = rand(5)
flying_log.sortie.full_stop = 1 + rand(3)
flying_log.save!
puts 'Sortie saved'

flying_log.sortie.total_landings = flying_log.sortie.touch_go.to_i + flying_log.sortie.full_stop.to_i
flying_log.sortie.flight_minutes  = flying_log.sortie.calculate_flight_minutes
flying_log.sortie.flight_time     = flying_log.sortie.calculate_flight_time
flying_log.sortie.total_landings  = flying_log.sortie.calculate_landings
flying_log.sortie.update_aircraft_times
flying_log.sortie.save
puts 'Sortie calculated'

flying_log.build_capt_after_flight
flying_log.capt_after_flight.flight_time = cur_time.strftime("%H:%M %p")
flying_log.capt_after_flight.user = User.where(role_cd: 7).first
flying_log.save
puts 'book in'
#sleep(2)
flying_log = FlyingLog.first
techlog_count = (2+rand(5))
for i in 1..techlog_count
   Techlog.create({type_cd: 1.to_s, log_time: "#{Time.zone.now.strftime("%H:%M %p")}", 
        description: Faker::Lorem.sentence, 
        #work_unit_code: WorkUnitCode.where(wuc_type_cd: 3).leaves.limit(1).offset(rand(3)).first, 
        user_id: User.where(role_cd: 7).first, 
        log_date: "#{Time.zone.now.strftime("%Y-%m-%d")}", 
        aircraft_id: flying_log.aircraft_id, flying_log_id: flying_log.id})
end
flying_log.pilot_back

