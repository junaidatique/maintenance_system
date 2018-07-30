class AutherizationCode
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  as_enum :type, Preflight: 0, Thru_Flight: 1, Post_Flight: 2, Weekly: 3, Other: 4
  as_enum :autherized_trade, Airframe: 0, Engine: 1, Electric: 2, Instrument: 3, Radio: 4, GRP: 5, CMO: 6, SEO: 7

  field :code, type: String
  field :inspection_type, type: String  

  has_many :techlogs
  has_many :work_packages
  has_and_belongs_to_many :user, class_name: User.name

  validates :code, presence: true
  validates :autherized_trade, presence: true
  validates :inspection_type, presence: true


  scope :preflight, -> { where(type_cd: 0) }
  scope :thru_Flight, -> { where(type_cd: 1) }
  scope :post_Flight, -> { where(type_cd: 2) }

  def self.import(file)    
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    (2..xlsx.last_row).each do |i|
      row                   = xlsx.row(i)
      puts row.inspect      
      code            = row[0]
      inspection_type = row[1]
      type            = row[2]
      trades          = row[3].to_s.split(',')
      pak_codes       = row[4].to_s.split(',')      
      trades.each do |trade|
        autherization_code = AutherizationCode.where(code: code).where(type: type).where(autherized_trade: trade).first
        if autherization_code.blank?
          autherization_code = AutherizationCode.create({
              code: code, inspection_type: inspection_type, type: type, autherized_trade: trade
            })
        end
        pak_codes.each do |pak_code|
          user = User.where(personal_code: pak_code).first
          if user.present? and !user.autherization_codes.include? autherization_code
            user.autherization_codes << autherization_code
          end
        end
      end      
    end
  end
  def autherization_code_format
    inspection_type
  end

end
