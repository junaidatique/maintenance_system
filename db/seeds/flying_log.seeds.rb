# rails db:seed:flying_log MIN=30 DAYS=0 INS=0 OFFSET=0
cur_time = Time.zone.now
date = Time.zone.now - (ENV['DAYS'].to_i).days
aircraft = Aircraft.limit(1).offset(ENV['OFFSET'].to_i).first
puts 'Creating Pre flight Flying Log'
flying_log = FlyingLog.new
last_flying_log = FlyingLog.last
if last_flying_log.present?
  flying_log.number = last_flying_log.number + 1
else
  flying_log.number = 1001
end
cur_time  = date

flying_log.log_date = date.strftime("%Y-%m-%d")
flying_log.aircraft = aircraft
flying_log.location_from = Faker::Lorem.word
flying_log.location_to = Faker::Lorem.word

flying_log.build_ac_configuration
flying_log.ac_configuration.clean = 1
flying_log.ac_configuration.smoke_pods = 1
flying_log.ac_configuration.third_seat = 1
flying_log.ac_configuration.cockpit_cd = 1 #+ rand(2)

flying_log.build_flightline_servicing
flying_log.flightline_servicing.user = User.where(role_cd: 15).first
flying_log.flightline_servicing.inspection_performed = ENV['INS'].to_i

flying_log.flightline_servicing.flight_start_time = cur_time
flying_log.flightline_servicing.flight_end_time   = (cur_time + (10*60)).strftime("%H:%M %p")
flying_log.flightline_servicing.hyd = Faker::Lorem.word
flying_log.created_at = date
flying_log.save!
flying_log.flightline_service

puts 'Flighline serviced'

flying_log.fuel_refill = 1 + rand(flying_log.aircraft.fuel_capacity)
flying_log.oil_serviced = 1 + rand(flying_log.aircraft.oil_capacity)
flying_log.update_fuel
flying_log.save
flying_log.fill_fuel

# # ToDo
flying_log.techlogs.where(type_cd: 0).each do |techlog|
  techlog.action = Faker::Lorem.sentence
  techlog.condition_cd = 1
  techlog.verified_tools = true
  techlog.user = User.where(role_cd: 5).first
  techlog.save!
end
flying_log.save!
# sleep(1)
flying_log.complete_servicing      
puts 'techlog finished'
flying_log.build_flightline_release
flying_log.flightline_release.flight_time = cur_time.strftime("%H:%M %p")
flying_log.flightline_release.user = User.where(role_cd: 1).first      
flying_log.save!      
flying_log.release_flight!

puts 'built_flightline_released'      
flying_log.build_capt_acceptance_certificate
flying_log.capt_acceptance_certificate.flight_time = cur_time.strftime("%H:%M %p")
flying_log.capt_acceptance_certificate.view_history = 1
flying_log.capt_acceptance_certificate.view_deffered_log = 1
flying_log.capt_acceptance_certificate.mission = "FLY PAST"
flying_log.capt_acceptance_certificate.user = User.where(role_cd: 5).first
flying_log.capt_acceptance_certificate.third_seat_name = Faker::Lorem.word
flying_log.book_flight
flying_log.save!
puts 'book out completed'
# #return
flying_log.build_sortie
flying_log.sortie.user = User.where(role_cd: 5).first
if flying_log.ac_configuration.cockpit_cd == 2
  flying_log.sortie.second_pilot = User.where(role_cd: 5).first
end

flying_log.sortie.takeoff_time = cur_time.strftime("%H:%M %p")
flying_log.sortie.landing_time = (cur_time + (ENV['MIN'].to_i) * 60).strftime("%H:%M %p")
flying_log.sortie.pilot_comment_cd = "SAT"
flying_log.sortie.touch_go = rand(5)
flying_log.sortie.full_stop = 1
flying_log.save!
puts 'Sortie saved'  

puts 'Sortie calculated'

flying_log.build_capt_after_flight
flying_log.capt_after_flight.flight_time = cur_time.strftime("%H:%M %p")
flying_log.capt_after_flight.user = User.where(role_cd: 5).first
flying_log.save!

puts 'Post mission report'
flying_log.build_post_mission_report
flying_log.post_mission_report.mission_date   = cur_time
flying_log.post_mission_report.oat            = 1
flying_log.post_mission_report.idle_rpm       = 2
flying_log.post_mission_report.max_rpm        = 3
flying_log.post_mission_report.cht            = 4
flying_log.post_mission_report.oil_temp       = 5
flying_log.post_mission_report.oil_pressure   = 6
flying_log.post_mission_report.map            = 7
flying_log.post_mission_report.mag_drop_left  = 8
flying_log.post_mission_report.mag_drop_right = 9
flying_log.post_mission_report.remarks        = Faker::Lorem.sentence
flying_log.post_mission_report.user           = User.where(role_cd: 5).first
flying_log.post_mission_report.aircraft       = flying_log.aircraft
flying_log.save!

puts 'book in'
flying_log.pilot_back
flying_log.pilot_confirmation
flying_log.sortie.remarks = flying_log.sortie.pilot_comment.to_s
flying_log.sortie.sortie_code_cd = 1
flying_log.techlog_check
flying_log.complete_log
flying_log.save

exit

Aircraft.limit(1).offset(6).first.parts.each do |part|
  part.part_histories.where(flying_log_id: nil).ne(hours: 40.8).each do |part_history|
    puts part_history.hours
  end
end
# ----------------------------------------------------------
# Aircraft.limit(1).offset(6).first.parts.where(trade_cd: 1).first.part_histories.where(flying_log_id: nil)