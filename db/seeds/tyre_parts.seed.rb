def create_part aircraft, category, trade, part_number, serial_no, quantity = 0, description = ''
  inspection_hours = 100
  inspection_calender_value = 1
  
  
  is_lifed = !serial_no.blank?

  calender_life_value = 1
  installed_date = nil
  if aircraft.present?
    installed_date  = Time.zone.now.strftime("%Y-%m-%d")
  end
  
  total_hours = 100
  
  
  print '.'
end
aircraft = Aircraft.first
tyres = [  
  {
    aircraft: aircraft, 
    number: 'Left Tyre', 
    serial_no: '61445895',       
    quantity: 1, 
    category: 'left_tyre',         
    description: 'Tyre', 
    is_lifed: false, 
    landings_completed: '277'    
  },
  {
    aircraft: aircraft, 
    number: 'Right Tyre', 
    serial_no: '61445879',       
    quantity: 1, 
    category: 'right_tyre',         
    description: 'Tyre', 
    is_lifed: false, 
    landings_completed: '277'    
  },
  {
    aircraft: aircraft, 
    number: 'Nose Tail',
    serial_no: '63562260',       
    quantity: 1, 
    category: 'nose_tail',         
    description: 'Tyre', 
    is_lifed: false, 
    landings_completed: '77'    
  }
]
tyres.each do |tyre|
  Part.create(tyre)
end