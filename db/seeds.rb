# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

preflight         = WorkUnitCode.create! code: 'preflight', description: 'Preflight'
preflight_crew    = WorkUnitCode.create! code: 'preflight_crew', 
                      description: 'Preflight Crew', parent_id: preflight, wuc_type_cd: 0
preflight_elect   = WorkUnitCode.create! code: 'preflight_elect', 
                      description: 'Preflight electrical', parent_id: preflight, wuc_type_cd: 0
preflight_radio   = WorkUnitCode.create! code: 'preflight_radio', 
                      description: 'Preflight Radio', parent_id: preflight, wuc_type_cd: 0
thru_flight       = WorkUnitCode.create! code: 'thru_flight', description: 'Thru_Flight'
thru_flight_crew  = WorkUnitCode.create! code: 'thru_flight_crew', 
                      description: 'Thru_Flight Crew', parent_id: thru_flight, wuc_type_cd: 1
thru_flight_elect = WorkUnitCode.create! code: 'thru_flight_elect', 
                      description: 'Thru_Flight electrical', parent_id: thru_flight, wuc_type_cd: 1
thru_flight_radio = WorkUnitCode.create! code: 'thru_flight_radio', 
                      description: 'Thru_Flight Radio', parent_id: thru_flight, wuc_type_cd: 1
post_flight       = WorkUnitCode.create! code: 'post_flight', description: 'Post_Flight'
post_flight_crew  = WorkUnitCode.create! code: 'post_flight_crew', 
                      description: 'Post_Flight Crew', parent_id: post_flight, wuc_type_cd: 2
post_flight_elect = WorkUnitCode.create! code: 'post_flight_elect', 
                      description: 'Post_Flight electrical', parent_id: post_flight, wuc_type_cd: 2
post_flight_radio = WorkUnitCode.create! code: 'post_flight_radio', 
                      description: 'Post_Flight Radio', parent_id: post_flight, wuc_type_cd: 2

admin       = User.create! username: 'admin', name: 'Admin', 
                role: :admin, password: '12345678', status: 1
engineer    = User.create! username: 'engineer', name: 'Engineer', 
                role: :engineer, password: '12345678', status: 1
crew        = User.create! username: 'crew', name: 'Crew Cheif', 
                role: :crew_cheif, password: '12345678', status: 1, work_unit_codes: [preflight_crew, thru_flight_crew, post_flight_crew]
electrical  = User.create! username: 'electrical', name: 'Electrical', 
                role: :electrical, password: '12345678', status: 1, work_unit_codes: [preflight_elect, thru_flight_elect, post_flight_elect]
radio       = User.create! username: 'radio', name: 'Radio', 
                role: :radio, password: '12345678', status: 1, work_unit_codes: [preflight_radio, thru_flight_radio, post_flight_radio]
pilot       = User.create! username: 'pilot', name: 'Pilot', 
                role: :pilot, password: '12345678', status: 1
master_control = User.create! username: 'master_control', name: 'Master Control', 
                role: :master_control, password: '12345678', status: 1

aircraft_300  = Aircraft.create! number: '300', tail_number: 'QS300', serial_no: '#300', fuel_capacity: '15', oil_capacity: '15'
Aircraft.create! number: '301', tail_number: 'QS301', serial_no: '#301', fuel_capacity: '15', oil_capacity: '15'


FlyingPlan.create! flying_date: Time.zone.now.strftime("%Y-%m-%d"), is_flying: true, aircraft_ids: [aircraft_300.id]
System.create! settings: {dms_version_number: 0.0}
