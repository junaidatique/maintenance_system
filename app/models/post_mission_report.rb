class PostMissionReport
  include Mongoid::Document    
  include Mongoid::Timestamps

  field :mission_date, type: String
  field :oat, type: String
  field :idle_rpm, type: String
  field :max_rpm, type: String
  field :cht, type: String
  field :oil_temp, type: String
  field :oil_pressure, type: String
  field :map, type: String
  field :mag_drop_left, type: String
  field :mag_drop_right, type: String
  field :remarks, type: String

  belongs_to :user
  belongs_to :flying_log
  belongs_to :aircraft

  validates :oat, presence: :true
  validates :idle_rpm, presence: :true
  validates :max_rpm, presence: :true
  validates :cht, presence: :true
  validates :oil_temp, presence: :true
  validates :oil_pressure, presence: :true
  validates :map, presence: :true
  validates :mag_drop_left, presence: :true
  validates :mag_drop_right, presence: :true
  
end
