cur_time = Time.zone.now

System.create! settings: {dms_version_number: 0.0}
#  s.update settings: {dms_version_number: 1.0}
puts 'Creating Aircraft'
(300..307).each do |aircraft|
  Aircraft.create! number: aircraft, tail_number: "QA#{aircraft}", serial_no: "##{aircraft}", fuel_capacity: '42', oil_capacity: '8' if Aircraft.where(number: aircraft).first.blank?
end
puts 'Aircraft Created'



puts 'Creating Users'
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
      "trade": "chief_maintenance_officer"
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
      "trade": "master_control"
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
      "trade": "master_control"
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
      "trade": "master_control"
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
      "personal_code": "AMF/422",
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
  

users_list.each do |user|  
  username  = user[:name].downcase.gsub(' ','_')
  u           = User.where(username: username).first_or_create  
  u.name      = user[:name].titleize  
  u.rank      = user[:rank]
  u.trade     = user[:trade]
  u.personal_code = user[:personal_code]
  u.password  = 'test1234'
  u.status    = 1
  u.role_cd   = User.roles[user[:trade].downcase.gsub(" ", "_")]
  u.trade     = user[:trade]
  u.save!    
  print '.'
end
puts ''
puts 'user created'
# exit
# puts 'Creating FlyingPlan'
# (0..10).each do |day|
#   is_flying     = 1
#   aircraft_ids  = []
#   reason = ''  
#   if (is_flying)
#     aircraft_ids = Aircraft.all.map{|aircraft| aircraft.id.to_s}
#   else
#     reason = Faker::Lorem.sentence(3)
#   end  
#   FlyingPlan.create! flying_date: (Time.zone.now - day.days).strftime("%Y-%m-%d"), is_flying: is_flying, aircraft_ids: aircraft_ids, reason: reason
#   print '.'
# end
# puts ''
# puts 'FlyingPlan Created'


# puts 'Creating WorkUnitCodes'
# WorkUnitCode.wuc_types.each do |work_unit_code,code_key|  
#   #w_code = WorkUnitCode.create code: work_unit_code.downcase, description: work_unit_code.to_s.sub('_',' ')
#   print '.'
  
#   ["crew_cheif"].each do |role_name, role_key|
#     work_unit_code_value = WorkUnitCode.create code: "#{work_unit_code.downcase}_#{role_name.downcase}", description: "#{work_unit_code.to_s.sub('_',' ')} #{role_name.to_s.sub('_',' ')}", wuc_type_cd: code_key
#     role_id = User::roles[role_name]
#     u = User.where(role_cd: role_id).first
#     unless u.blank?
#       u.work_unit_codes << work_unit_code_value
#       u.save
#     end
#   end
# end
# puts ''
# puts 'WorkUnitCodes Created'

puts 'Creating Aircraft Inspection'
aircraft_inspections = [
  {
    kind_cd: 1,
    type_cd: 0,
    category_cd: 1,    
    name: 'Aircraft 25 HRS', 
    no_of_hours: 25,    
    is_repeating: false    
  },
  {
    kind_cd: 1,
    type_cd: 0,
    category_cd: 1,    
    duration_cd: 1,
    name: 'Aircraft 50 HRS', 
    no_of_hours: 50,
    calender_value: 6,
    is_repeating: true    
  },  
  {
    kind_cd: 1,
    type_cd: 0,
    category_cd: 1,    
    duration_cd: 2,
    name: 'Aircraft 100 HRS', 
    no_of_hours: 100,
    calender_value: 1,
    is_repeating: true
  },    
  {
    kind_cd: 1,
    type_cd: 0,
    category_cd: 1,    
    name: 'Aircraft 400 HRS',
    no_of_hours: 400,    
    is_repeating: true 
  }, 
  {
    kind_cd: 1,
    type_cd: 0,
    category_cd: 2,
    duration_cd: 1,
    name: 'Aircraft Engine oil INSP Due', 
    no_of_hours: 0, 
    calender_value: 4,
    is_repeating: true    
  },   
  {
    kind_cd: 1,
    type_cd: 0,
    category_cd: 2,
    duration_cd: 0,
    name: 'Aircraft Weekly', 
    no_of_hours: 0, 
    calender_value: 7,
    is_repeating: true
  },
  {
    kind_cd: 1,
    type_cd: 0,
    category_cd: 2,
    duration_cd: 2,
    name: 'Aircraft Compass Swing INSP Due', 
    no_of_hours: 0, 
    calender_value: 1,
    is_repeating: true
  },
  {
    kind_cd: 1,
    type_cd: 0,
    category_cd: 2,
    duration_cd: 1,
    name: 'Aircraft Fire Bottle INSP Due', 
    no_of_hours: 0, 
    calender_value: 1,
    is_repeating: true
  }
]   
 
aircraft_inspections.each do |insp|  
  # last_conducted_dates = insp[:last_conducted_dates]  
  # last_conducted_hours = insp[:last_conducted_hours]  
  # insp.delete(:last_conducted_dates)  
  # insp.delete(:last_conducted_hours)  
  inspection = Inspection.where(name: insp[:name]).first_or_create
  inspection.kind_cd = insp[:kind_cd]
  inspection.type_cd = insp[:type_cd]
  inspection.category_cd = insp[:category_cd]
  inspection.duration_cd = insp[:duration_cd]
  inspection.no_of_hours = insp[:no_of_hours]
  inspection.calender_value = insp[:calender_value]
  inspection.is_repeating = insp[:is_repeating]
  inspection.save!
  # aircrafts = Aircraft.all
  # aircrafts.each do |aircraft|
  #   last_conducted = Time.zone.now
  #   if last_conducted_dates.present?
  #     last_conducted = last_conducted_dates[aircraft.number]
  #   end
    
  #   last_inspection_hour = 0    
  #   if last_conducted_hours.present?
  #     last_inspection_hour = last_conducted_hours[aircraft.number]    
  #   end
    
  #   inspection.create_aircraft_inspection aircraft, last_conducted, last_inspection_hour    
  # end  
end
puts 'Aircraft Inspection Created'

part_inspections = [
  {
    type_cd: 1,    
    kind_cd: 1,
    name: 'Engine 10 hour', 
    no_of_hours: 10,    
    is_repeating: false,
    part_number: 'ENPL-RT10227'
  },
  {
    type_cd: 1,
    kind_cd: 1,    
    name: 'Engine 25 hour', 
    no_of_hours: 25,    
    is_repeating: false,
    part_number: 'ENPL-RT10227'
  },
  # {
  #   type_cd: 1,
  #   kind_cd: 1,    
  #   name: 'Engine 1000 hour', 
  #   no_of_hours: 1000,    
  #   is_repeating: false,
  #   part_number: 'ENPL-RT10227'
  # },
  {
    type_cd: 1,
    kind_cd: 1,    
    name: 'Prop 10 hour Inspection', 
    no_of_hours: 10,    
    is_repeating: false,
    part_number: 'HC-C2YK-1BF I/L C2K00180'
  },
  # {
  #   type_cd: 1,
  #   kind_cd: 1,    
  #   name: 'Prop 100 hour Inspection', 
  #   no_of_hours: 100,    
  #   is_repeating: true,
  #   part_number: 'HC-C2YK-1BF I/L C2K00180',
  #   calender_value: 1,
  #   duration_cd: 2,
  # }
]
part_inspections.each do |insp|
  inspection = Inspection.where(name: insp[:name]).first_or_create
  inspection.kind_cd = insp[:kind_cd]
  inspection.type_cd = insp[:type_cd]
  inspection.category_cd = insp[:category_cd]
  inspection.duration_cd = insp[:duration_cd]
  inspection.no_of_hours = insp[:no_of_hours]
  inspection.calender_value = insp[:calender_value]
  inspection.is_repeating = insp[:is_repeating]
  inspection.part_number = insp[:part_number]
  inspection.save!
  # inspection = Inspection.create(insp)  
end
exit
# def create_part aircraft, category, trade, part_number, serial_no, quantity = 0, description = ''
#   inspection_hours = 100
#   inspection_calender_value = 1
  
  
#   is_lifed = !serial_no.blank?

#   calender_life_value = 1
#   installed_date = nil
#   if aircraft.present?
#     installed_date  = Time.zone.now.strftime("%Y-%m-%d")
#   end
  
#   total_hours = 100
  
#   Part.create({
#     aircraft: aircraft, 
#     number: part_number, 
#     serial_no: serial_no,       
#     quantity: quantity, 
#     category: category, 
#     trade: trade, 
    
#     inspection_hours: inspection_hours, 
#     inspection_calender_value: inspection_calender_value, 
    
#     description: description, 
#     is_lifed: is_lifed, 
#     calender_life_value: calender_life_value, 
#     installed_date: installed_date, 
#     total_hours: total_hours })
#   print '.'
# end



# puts 'Creating Parts'
# Part::categories.each do |category,value|
#   if value == 0
#     part_number = 'ENPL-RT10227'
#   elsif value == 1
#     part_number = 'HC-C2YK-1BF I/L C2K00180'
#   else
#     part_number = "#{Faker::Number.number(8)}-#{Faker::Number.number(4)}"  
#   end
  
#   (0..Aircraft.count - 1).each do |j|
#     aircraft    = Aircraft.limit(1).offset(j).first
#     # serial_no   = "#{Faker::Number.number(5)}"
#     serial_no   = aircraft.tail_number
#     create_part aircraft, category, nil, part_number, serial_no, 1, category
#   end
#   (0..3).each do |j|  
#     serial_no   = "#{Faker::Number.number(5)}"
#     create_part nil, category, nil, part_number, serial_no, 1, category
#   end  
#   print '.'
# end
# puts ''
# puts 'Categorise Part Created'
# Part::trades.each do |trade,value|  
#   (0..Aircraft.count).each do |j|
#     (0..3).each do |j|  
#       desc = Faker::Lorem.words(1 + rand(4)).join(" ")
#       part_number = "#{Faker::Number.number(8)}-#{Faker::Number.number(4)}"  
#       aircraft    = Aircraft.limit(1).offset(j).first
#       serial_no   = "#{Faker::Number.number(5)}"
#       create_part aircraft, nil, trade, part_number, serial_no, 1, desc
#     end    
#   end  
#   print '.'
# end
# puts ''
# puts 'Trade Part Created'

# (0..5).each do |j|
#   part_number  = "#{Faker::Number.number(8)}-#{Faker::Number.number(4)}"  
#   desc = Faker::Lorem.words(1 + rand(4)).join(" ")
#   create_part nil, nil, nil, part_number, nil, rand(10) + 1, desc
#   print '.'
# end
# puts ''
# puts 'Unserialized Part Created'

# puts ''
# puts 'Part Created'
# exit
##################################################################
#sleep(2)
(0..2).each do |day|
  date = Time.zone.now - (8 - day).days
  FlightlineServicing::inspection_performeds.each do |inspection,inspection_id|
    
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
    f.fill_fuel
    f.techlogs.where(type_cd: 0).each do |techlog|
      techlog.action = Faker::Lorem.sentence
      techlog.verified_tools = 1
      techlog.condition_cd = 1
      techlog.save!
    end
    # flying_log.complete_log    
      # break
    # end    
    # break
  end  
  # break
end

puts 'All done'
# break;
# a = Aircraft.first
# a.flying_logs.each do |f|
#   a.update_part_values f
# end
