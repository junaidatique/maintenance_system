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
    landings_completed: 277
  },
  {
    aircraft: aircraft, 
    number: 'Right Tyre', 
    serial_no: '61445879',       
    quantity: 1, 
    category: 'right_tyre',         
    description: 'Tyre', 
    is_lifed: false, 
    landings_completed: 277
  },
  {
    aircraft: aircraft, 
    number: 'Nose Tail',
    serial_no: '63562260',       
    quantity: 1, 
    category: 'nose_tail',         
    description: 'Tyre', 
    is_lifed: false, 
    landings_completed: 77    
  }
]
tyres.each do |tyre|
  Part.create(tyre)
end