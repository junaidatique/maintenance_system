class WorkUnitCode
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  

  field :code, type: String
  field :description, type: String
  as_enum :trade, Airframe: 0, Engine: 1, Electric: 2, Instrument: 3, Radio: 4, GRP: 5, CMO: 6, SEO: 7



  has_many :techlogs  
  
  validates :code, presence: true, uniqueness: true  
  

  def self.import(file)    
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    (2..xlsx.last_row).each do |i|
      row                   = xlsx.row(i)
      code        = row[0]
      description = row[1]
      trade       = row[2]
      wuc = WorkUnitCode.where(code: code.to_s).first
      if wuc.blank?
        wuc = WorkUnitCode.create({code: code.to_s, description: description.to_s, trade: trade })
      else
        wuc.update({code: code.to_s, description: description.to_s, trade: trade })
      end      
    end
  end

end
