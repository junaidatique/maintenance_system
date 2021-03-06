class Tool
  include Mongoid::Document
  include Mongoid::Timestamps

  field :number, type: String
  field :serial_no, type: String
  field :name, type: String
  field :unit_of_measurement, type: String
  field :total_quantity, type: Integer
  field :quantity_in_hand, type: Integer
  field :puc, type: String
  field :total_cost, type: String
  

  has_many :assigned_tools, dependent: :destroy, inverse_of: :tool

  def self.import(file)    
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)    
    header = xlsx.row(1)    
    (3..xlsx.last_row).each do |i|
      row         = xlsx.row(i)
      number      = row[0]      
      name        = row[1]
      unit_of_measurement  = row[2]      
      quantity    = row[3]
      serial_no   = row[4]      
      tool        = Tool.where(serial_no: serial_no)
      if tool.present?
        tool.update({
          number: number, 
          total_quantity: quantity, 
          name: name, 
          quantity_in_hand: quantity, 
          unit_of_measurement: unit_of_measurement,          
          serial_no: serial_no 
        })
      else
        Tool.create({
          number: number, 
          total_quantity: quantity, 
          name: name, 
          quantity_in_hand: quantity, 
          unit_of_measurement: unit_of_measurement,                    
          serial_no: serial_no
        })
      end
      # break;
    end
  end

end
