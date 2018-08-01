class WorkPackage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description, type: String

  belongs_to :inspection
  belongs_to :autherization_code

  def self.import inspection, file
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    (5..xlsx.last_row).each do |i|
      row               = xlsx.row(i) 
      description       = row[1]

      next if description.blank? or row[2].blank?

      autherization_code    = AutherizationCode.where(code: row[2]).first
      if autherization_code.blank?
        WorkPackage.create({
          inspection: inspection, 
          description: description, 
          autherization_code: autherization_code
        })
      end
      
      # break;
    end
  end
end
