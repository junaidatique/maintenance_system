cur_time = Time.now

System.create! settings: {dms_version_number: 0.0}
puts 'Creating Aircraft'
aircraft_300  = Aircraft.create! number: '300', tail_number: 'QA300', serial_no: '#300', fuel_capacity: '50', oil_capacity: '50', flight_hours: 0, engine_hours: 0, landings: 0, prop_hours: 0
aircraft_301  = Aircraft.create! number: '301', tail_number: 'QA301', serial_no: '#301', fuel_capacity: '50', oil_capacity: '50', flight_hours: 0, engine_hours: 0, landings: 0, prop_hours: 0
aircraft_302  = Aircraft.create! number: '302', tail_number: 'QA302', serial_no: '#302', fuel_capacity: '50', oil_capacity: '50', flight_hours: 0, engine_hours: 0, landings: 0, prop_hours: 0
aircraft_303  = Aircraft.create! number: '303', tail_number: 'QA303', serial_no: '#303', fuel_capacity: '50', oil_capacity: '50', flight_hours: 0, engine_hours: 0, landings: 0, prop_hours: 0
aircraft_303  = Aircraft.create! number: '304', tail_number: 'QA304', serial_no: '#304', fuel_capacity: '50', oil_capacity: '50', flight_hours: 0, engine_hours: 0, landings: 0, prop_hours: 0
aircraft_303  = Aircraft.create! number: '305', tail_number: 'QA305', serial_no: '#305', fuel_capacity: '50', oil_capacity: '50', flight_hours: 0, engine_hours: 0, landings: 0, prop_hours: 0
aircraft_303  = Aircraft.create! number: '306', tail_number: 'QA306', serial_no: '#306', fuel_capacity: '50', oil_capacity: '50', flight_hours: 0, engine_hours: 0, landings: 0, prop_hours: 0
aircraft_303  = Aircraft.create! number: '307', tail_number: 'QA307', serial_no: '#307', fuel_capacity: '50', oil_capacity: '50', flight_hours: 0, engine_hours: 0, landings: 0, prop_hours: 0

users_list = [
      {
      "sno": 0,
      "rank": "",
      "name": "admin",
      "personal_code": "",
      "trade": "Admin"
    },
    {
      "sno": 1,
      "rank": "Maj Gen",
      "name": "SALEM",
      "personal_code": "1848",
      "trade": "PILOT"
    },
    {
      "sno": 2,
      "rank": "Brig Gen",
      "name": "YOUSAF",
      "personal_code": "1849",
      "trade": "PILOT"
    },
    {
      "sno": 3,
      "rank": "Col",
      "name": "ATA",
      "personal_code": "10899",
      "trade": "PILOT"
    },
    {
      "sno": 4,
      "rank": "Lt Col",
      "name": "MUAZZAM",
      "personal_code": "11020",
      "trade": "chief_maintenance_officer"
    },
    {
      "sno": 5,
      "rank": "Lt Col",
      "name": "SHAHERYAR",
      "personal_code": "11693",
      "trade": "PILOT"
    },
    {
      "sno": 6,
      "rank": "Maj",
      "name": "SHAMSI",
      "personal_code": "12555",
      "trade": "ENGG"
    },
    {
      "sno": 7,
      "rank": "Maj",
      "name": "SHAHID",
      "personal_code": "12582",
      "trade": "LOGISTICS"
    },
    {
      "sno": 8,
      "rank": "Maj",
      "name": "SHAHBAZ",
      "personal_code": "14669",
      "trade": "PILOT"
    },
    {
      "sno": 9,
      "rank": "Maj",
      "name": "ATIF",
      "personal_code": "14724",
      "trade": "PILOT"
    },
    {
      "sno": 10,
      "rank": "Maj",
      "name": "ADEEL",
      "personal_code": "14754",
      "trade": "PILOT"
    },
    {
      "sno": 11,
      "rank": "Capt",
      "name": "JAWAD",
      "personal_code": "N/A",
      "trade": "PILOT"
    },
    {
      "sno": 12,
      "rank": "Capt",
      "name": "BASIT",
      "personal_code": "N/A",
      "trade": "PILOT"
    },
    {
      "sno": 13,
      "rank": "Capt",
      "name": "ZAHID",
      "personal_code": "N/A",
      "trade": "PILOT"
    },
    {
      "sno": 14,
      "rank": "Capt",
      "name": "ZAHEER",
      "personal_code": "N/A",
      "trade": "PILOT"
    },
    {
      "sno": 15,
      "rank": "Wrt Off",
      "name": "DOST",
      "personal_code": "857352",
      "trade": "INST Fitt"
    },
    {
      "sno": 16,
      "rank": "Chf Tech",
      "name": "RASHID",
      "personal_code": "858778",
      "trade": "ENG Fitt"
    },
    {
      "sno": 17,
      "rank": "Chf Tech",
      "name": "JAMIL",
      "personal_code": "859024",
      "trade": "AFR Fitt"
    },
    {
      "sno": 18,
      "rank": "Chf Tech",
      "name": "MANSOOR",
      "personal_code": "859282",
      "trade": "crew_cheif"
    },
    {
      "sno": 19,
      "rank": "Chf Tech",
      "name": "AYUB",
      "personal_code": "859302",
      "trade": "AFR Fitt"
    },
    {
      "sno": 20,
      "rank": "Chf Tech",
      "name": "RAFIQUE",
      "personal_code": "859820",
      "trade": "RO Fitt"
    },
    {
      "sno": 21,
      "rank": "Chf Tech",
      "name": "GHULAM MOHAYUDIN",
      "personal_code": "860610",
      "trade": "master_control"
    },
    {
      "sno": 22,
      "rank": "Chf Tech",
      "name": "EJAZ",
      "personal_code": "861135",
      "trade": "AFR Fitt"
    },
    {
      "sno": 23,
      "rank": "Chf Tech",
      "name": "SADIQ",
      "personal_code": "862262",
      "trade": "AFR Fitt"
    },
    {
      "sno": 24,
      "rank": "Chf Tech",
      "name": "SAJJAD",
      "personal_code": "862296",
      "trade": "ENG Fitt"
    },
    {
      "sno": 25,
      "rank": "Snr Tech",
      "name": "AKRAM",
      "personal_code": "496446",
      "trade": "LOG ASST"
    },
    {
      "sno": 26,
      "rank": "Snr Tech",
      "name": "DILDAR",
      "personal_code": "868183",
      "trade": "ELECT Fitt"
    },
    {
      "sno": 27,
      "rank": "Cpl Tech",
      "name": "AAMIR",
      "personal_code": "869207",
      "trade": "ELECT Fitt"
    },
    {
      "sno": 28,
      "rank": "Cpl Tech",
      "name": "SAEED",
      "personal_code": "871107",
      "trade": "AFR Fitt"
    },
    {
      "sno": 29,
      "rank": "Cpl Tech",
      "name": "BILAL",
      "personal_code": "871199",
      "trade": "ENG Fitt"
    },
    {
      "sno": 30,
      "rank": "Cpl Tech",
      "name": "ABDULLAH",
      "personal_code": "871401",
      "trade": "AFR Fitt"
    },
    {
      "sno": 31,
      "rank": "Cpl Tech",
      "name": "AKHTAR",
      "personal_code": "871672",
      "trade": "ELECT Fitt"
    },
    {
      "sno": 32,
      "rank": "Cpl Tech",
      "name": "JAVED",
      "personal_code": "871915",
      "trade": "INST Fitt"
    },
    {
      "sno": 33,
      "rank": "Cpl Tech",
      "name": "WASEEM",
      "personal_code": "872832",
      "trade": "ENG Fitt"
    },
    {
      "sno": 34,
      "rank": "CH/H",
      "name": "SIKANDAR",
      "personal_code": "AMF/0422",
      "trade": "GEN Fitt"
    },
    {
      "sno": 35,
      "rank": "MC-1",
      "name": "TAJ",
      "personal_code": "AMF/1012",
      "trade": "RO Fitt"
    }
  ]
  
  puts 'creating users'
  users_list.each do |user|
    # puts user[:sno].inspect
    u = User.new
    u.name = user[:name].titleize
    u.username = user[:name].downcase.gsub(' ','_')
    u.rank = user[:rank]
    u.trade = user[:trade]
    u.personal_code = user[:personal_code]
    u.password = 'test1234'
    u.status = 1
    u.role_cd = User.roles[user[:trade].downcase.gsub(" ", "_")]
    u.trade = user[:trade]
    u.save!    
    print '.'
  end
  puts ''
  puts 'user created'
puts 'Creating FlyingPlan'
(0..10).each do |day|
  is_flying     = 1
  aircraft_ids  = []
  reason = ''
  if (is_flying)
    aircraft_ids = Aircraft.limit(1+rand(Aircraft.count)).sort_by{rand}.map{|aircraft| aircraft.id.to_s}
  else
    reason = Faker::Lorem.sentence(3)
  end  
  FlyingPlan.create! flying_date: (Time.now - day.days).strftime("%Y-%m-%d"), is_flying: is_flying, aircraft_ids: aircraft_ids, reason: reason
  print '.'
end
puts ''
puts 'FlyingPlan Created'


puts 'Creating WorkUnitCodes'
WorkUnitCode.wuc_types.each do |work_unit_code,code_key|  
  w_code = WorkUnitCode.create code: work_unit_code.downcase, description: work_unit_code.to_s.sub('_',' ')
  print '.'
  
  ["crew_cheif"].each do |role_name, role_key|
    work_unit_code_value = WorkUnitCode.create code: "#{work_unit_code.downcase}_#{role_name.downcase}", description: "#{work_unit_code.to_s.sub('_',' ')} #{role_name.to_s.sub('_',' ')}", parent_id: w_code, wuc_type_cd: code_key
    role_id = User::roles[role_name]
    u = User.where(role_cd: role_id).first
    unless u.blank?
      u.work_unit_codes << work_unit_code_value
      u.save
    end
  end
end
puts ''
puts 'WorkUnitCodes Created'

# (0..Aircraft.count).each do |j|
#   aircraft = Aircraft.limit(1).offset(j).first
#   (1..16).each do |i|
#     calender_life = ''
#     installed_date = (cur_time).strftime("%Y-%m-%d")
#     total_hours = 0
#     total_landings = 0
#     is_lifed = false
#     if i == 5 or i == 6 or i == 7 or i == 8
#       is_lifed = true
#       calender_life = (cur_time + (60*60*24*365)).strftime("%Y-%m-%d")
#     elsif i == 9 or i == 10 or i == 11 or i == 12
#       is_lifed = true
#       total_hours = 400
#     elsif i == 13 or i == 14 or i == 15 or i == 16
#       is_lifed = true
#       total_landings = 200
#     end
#     part_number = "#{Faker::Number.number(8)}"
#     serial_no = "#{Faker::Number.number(5)}"
#     part_number_serial_no = "#{part_number}-#{serial_no}"
#     quantity = rand(10) + 1
#     Part.create({
#       aircraft: aircraft, number: part_number, 
#       serial_no: serial_no, 
#       number_serial_no: part_number_serial_no, 
#       quantity: quantity, 
#       quantity_left: quantity, 
#       description: Faker::Lorem.words(1 + rand(4)).join(" "), 
#       is_lifed: is_lifed, calender_life: calender_life, installed_date: installed_date, 
#       total_hours: total_hours, total_landings: total_landings })
#   end
# end

# puts 'Aircraft Created'
# puts 'Creating Tools'
# (0..24).each do |tool|
#   print '.'
#   quantity = 1 + rand(4)
#   Tool.create({number: "#{Faker::Number.number(8)}", name: Faker::Lorem.word, total_quantity: quantity, quantity_in_hand: quantity})
# end
# puts ''
# puts 'Tools Created'

# # puts 'Creating Users'
# # User.roles.each do |role_name, role_key|
# #   User.create! username: role_name, name: role_name.to_s.sub('_',' '), 
# #                 role: role_name, password: 'test1234', status: 1, personal_code: Faker::Number.number(6), rank: Faker::Lorem.word
# #   print '.'
# # end
# # puts ''
# # puts 'Users Created'


# # return
# ##################################################################
# #sleep(2)
# (0..1).each do |fl_log|
#   puts 'Creating Pre flight Flying Log'
# flying_log = FlyingLog.new
# last_flying_log = FlyingLog.last
# if last_flying_log.present?
#   flying_log.number = last_flying_log.number + 1
# else
#   flying_log.number = 1001
# end
# cur_time  = Time.now

# flying_log.log_date = Time.now.strftime("%Y-%m-%d")
# flying_log.aircraft = Aircraft.active.available.first
# flying_log.location_from = Faker::Lorem.word
# flying_log.location_to = Faker::Lorem.word

# flying_log.build_ac_configuration
# flying_log.ac_configuration.clean = 1
# flying_log.ac_configuration.smoke_pods = 1
# flying_log.ac_configuration.third_seat = 1
# flying_log.ac_configuration.cockpit_cd = 1 #+ rand(2)

# flying_log.build_flightline_servicing
# flying_log.flightline_servicing.user = User.where(role_cd: 7).first
# flying_log.flightline_servicing.inspection_performed = 0

# flying_log.flightline_servicing.flight_start_time = cur_time.strftime("%H:%M %p")
# flying_log.flightline_servicing.flight_end_time   = (cur_time + (10*60)).strftime("%H:%M %p")
# flying_log.flightline_servicing.hyd = Faker::Lorem.word

# flying_log.save
# flying_log.flightline_service

# puts 'Flighline serviced'

# flying_log.fuel_refill = 1 + rand(flying_log.aircraft.fuel_capacity)
# flying_log.oil_serviced = 1 + rand(flying_log.aircraft.oil_capacity)
# flying_log.update_fuel
# flying_log.save
# flying_log.fill_fuel

# # ToDo
# flying_log.techlogs.where(type_cd: 0).each do |techlog|
#   techlog.action = Faker::Lorem.sentence
#   techlog.condition_cd = 1
#   techlog.save
# end
# puts 'techlog finished'
# flying_log.build_flightline_release
# flying_log.flightline_release.flight_time = cur_time.strftime("%H:%M %p")
# flying_log.flightline_release.user = User.where(role_cd: 7).first
# flying_log.flight_release
# flying_log.save
# puts 'build_flightline_released'
# flying_log.build_capt_acceptance_certificate
# flying_log.capt_acceptance_certificate.flight_time = cur_time.strftime("%H:%M %p")
# flying_log.capt_acceptance_certificate.view_history = 1
# flying_log.capt_acceptance_certificate.mission_cd = FLYPAST
# flying_log.capt_acceptance_certificate.user = User.where(role_cd: 8).first
# flying_log.book_flight
# flying_log.save
# puts 'book out completed'
# #return
# flying_log.build_sortie
# flying_log.sortie.user = User.where(role_cd: 8).first
# if flying_log.ac_configuration.cockpit_cd == 2
#   flying_log.sortie.second_pilot = User.where(role_cd: 13).first
# end
# flying_log.sortie.third_seat_name = Faker::Lorem.word
# flying_log.sortie.takeoff_time = (cur_time - (10*60)).strftime("%H:%M %p")
# flying_log.sortie.landing_time = (cur_time + (10*60)).strftime("%H:%M %p")
# flying_log.sortie.pilot_comment = 'Un_satisfactory'
# flying_log.sortie.touch_go = rand(5)
# flying_log.sortie.full_stop = 1 + rand(3)
# flying_log.save!
# puts 'Sortie saved'

# flying_log.sortie.total_landings = flying_log.sortie.touch_go.to_i + flying_log.sortie.full_stop.to_i
# flying_log.sortie.flight_minutes  = flying_log.sortie.calculate_flight_minutes
# flying_log.sortie.flight_time     = flying_log.sortie.calculate_flight_time
# flying_log.sortie.total_landings  = flying_log.sortie.calculate_landings
# flying_log.sortie.update_aircraft_times
# flying_log.sortie.save
# puts 'Sortie calculated'

# flying_log.build_capt_after_flight
# flying_log.capt_after_flight.flight_time = cur_time.strftime("%H:%M %p")
# flying_log.capt_after_flight.user = User.where(role_cd: 7).first
# flying_log.save
# puts 'book in'
# flying_log.pilot_back
# #sleep(2)
# # flying_log = FlyingLog.first
# techlog_count = (8+rand(5))
# puts "techlog count #{techlog_count}"
# puts "createing techlogs"
# flying_log.sortie.sortie_code = 2
# for i in 1..techlog_count
#   print '.'
#   Techlog.create!({type_cd: 1.to_s, log_time: "#{Time.zone.now.strftime("%H:%M %p")}", 
#         description: Faker::Lorem.sentence, 
#         work_unit_code: WorkUnitCode.where(wuc_type_cd: 3).leaves.sort_by{rand}.first, 
#         user_id: User.where(role_cd: 7).first, 
#         log_date: "#{Time.zone.now.strftime("%Y-%m-%d")}", 
#         aircraft_id: flying_log.aircraft_id, flying_log_id: flying_log.id})
# end
# puts ''
# flying_log.save!
# flying_log.techlog_check
# flying_log.techlogs.where(type_cd: 1.to_s).each do |techlog|
#   techlog.action = Faker::Lorem.sentence
#   techlog.condition_cd = 1
#   techlog.save
# end
# flying_log.complete_log
# end


# puts 'All done'

