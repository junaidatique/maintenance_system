class Tool
  include Mongoid::Document
  include Mongoid::Timestamps

  field :number, type: String
  field :name, type: String
  field :total_quantity, type: Integer
  field :quantity_in_hand, type: Integer

  has_many :assigned_tools, dependent: :destroy, inverse_of: :tool

  def self.import(file)    
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)    
    header = xlsx.row(1)    
    (2..xlsx.last_row).each do |i|
      row       = xlsx.row(i)
      number    = row[0]
      name      = row[1]
      quantity  = row[2]
      tool      = Tool.where(number: number)
      if tool.present?
        tool.update({total_quantity: quantity, name: name})
      else
        Tool.create({number: number, total_quantity: quantity, name: name, quantity_in_hand: quantity })
      end

    end
  end

end
