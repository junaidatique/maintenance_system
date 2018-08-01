class WorkUnitCode
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  as_enum :trade, Airframe: 0, Engine: 1, Electric: 2, Instrument: 3, Radio: 4, GRP: 5, CMO: 6, SEO: 7

  field :code, type: String
  field :description, type: String  

  has_many :techlogs

  validates :code, presence: true, uniqueness: true  
  
  def self.import(file)    
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    (2..xlsx.last_row).each do |i|
      row                   = xlsx.row(i)      
      wuc         = WorkUnitCode.where(code: row[0].to_s).first
      description = row[1]
      trade       = row[2]
      if wuc.blank?
        wuc = WorkUnitCode.create({code: row[0].to_s, description: description, trade: trade })
      else
        wuc = wuc.update({description: description, wuc_type_cd: wuc_type_cd })
      end
      unless user.blank?
        
        if row[3] == 'preflight'
          wuc_type_cd = 0
        elsif row[3] == 'thru_flight'
          wuc_type_cd = 1
        elsif row[3] == 'post_flight'
          wuc_type_cd = 2
        elsif row[3] == 'other'
          wuc_type_cd = 3
        else
          next;
        end
        if wuc.blank?
          
        end
        if !user.work_unit_codes.include? wuc
          user.work_unit_codes << wuc
        end
        
      end
    end
  end

end
