class WorkPackage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description, type: String

  belongs_to :inspection
  belongs_to :work_unit_code

  def self.import inspection, file
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    (5..xlsx.last_row).each do |i|
      row               = xlsx.row(i) 
      description       = row[1]

      next if description.blank? or row[2].blank?

      work_unit_code    = WorkUnitCode.where(code: row[2]).first
      if work_unit_code.blank?
        work_unit_code  = WorkUnitCode.create({code: row[2], description: row[2], wuc_type_cd: 3})
      end
      WorkPackage.create({inspection: inspection, description: description, work_unit_code: work_unit_code})
      # break;
    end
  end
end
