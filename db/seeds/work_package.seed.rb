
#rails db:seed:create_work_package
puts 'here'
Inspection.all.each do |insp|  
  autherization_code    = AutherizationCode.first  
  WorkPackage.create!({
    inspection: insp, 
    description: Faker::Lorem.sentence, 
    autherization_code: autherization_code
  })
end