class WorkUnitCode
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Tree
  include Mongoid::Tree::Ordering
  include SimpleEnum::Mongoid

  as_enum :wuc_type, Preflight: 0, Thru_Flight: 1, Post_Flight: 2, Other: 3

  field :code, type: String
  field :description, type: String


  has_many :techlogs
  has_many :work_packages
  has_and_belongs_to_many :user, class_name: User.name

  scope :preflight, -> { where(wuc_type_cd: 0) }
  scope :thru_flight, -> { where(wuc_type_cd: 1) }
  scope :post_flight, -> { where(wuc_type_cd: 2) }
  scope :other, -> { where(wuc_type_cd: 3) }

  validates :code, presence: true, uniqueness: true  

  accepts_nested_attributes_for :children

  def self.import(file)    
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    (2..xlsx.last_row).each do |i|
      row                   = xlsx.row(i)      
      user  = User.where(personal_code: row[0]).first
      unless user.blank?
        wuc = WorkUnitCode.where(code: row[1].to_s).first
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
          wuc = WorkUnitCode.create({code: row[1].to_s, description: row[2].to_s, wuc_type_cd: wuc_type_cd })
        end
        if !user.work_unit_codes.include? wuc
          user.work_unit_codes << wuc
        end
        
      end
    end
  end

end
