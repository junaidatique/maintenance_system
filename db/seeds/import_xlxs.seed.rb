AutherizationCode.import './xlsx/code.xlsx'
Tool.import './xlsx/tools.xlsx'

xlsx = Roo::Spreadsheet.open('./xlsx/aircraft_summary.xlsx', extension: :xlsx)
(4..xlsx.last_row).each do |i|
  row               = xlsx.row(i)      
  puts row[0].inspect
  # puts row.inspect
  aircraft = Aircraft.where(number: row[0]).first
  aircraft.flight_hours = row[1]
  aircraft.engine_hours = row[2]
  aircraft.landings     = row[3]
  aircraft.prop_hours   = row[4]
  aircraft.save
  
  inspection = Inspection.aircraft_25_hour.first
  inspection.create_aircraft_inspection aircraft

  inspection = Inspection.aircraft_50_hour.first
  inspection.create_aircraft_inspection aircraft, row[6], row[5]

  inspection = Inspection.aircraft_100_hour.first
  inspection.create_aircraft_inspection aircraft, row[8], row[7]
  
  inspection = Inspection.aircraft_400_hour.first
  inspection.create_aircraft_inspection aircraft

  inspection = Inspection.where(name: 'Aircraft Engine oil INSP Due').first
  inspection.create_aircraft_inspection aircraft, row[9]

  inspection = Inspection.where(name: 'Aircraft Weekly').first
  inspection.create_aircraft_inspection aircraft, row[10]
  
  inspection = Inspection.where(name: 'Aircraft Compass Swing INSP Due').first
  inspection.create_aircraft_inspection aircraft, row[11]
  
  inspection = Inspection.where(name: 'Aircraft Fire Bottle INSP Due').first
  inspection.create_aircraft_inspection aircraft, row[12]
  aircraft.import "./xlsx/#{aircraft.number}.xlsx"
  break
end




inspection = Inspection.where(name: 'Aircraft Weekly').first
AutherizationCode.where(type_cd: 3).each do |auth|
  WorkPackage.create!({
    inspection: inspection, 
    description: auth.inspection_type, 
    autherization_code: auth
  })
end