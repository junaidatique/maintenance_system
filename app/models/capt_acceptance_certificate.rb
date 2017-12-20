class CaptAcceptanceCertificate
  include Mongoid::Document
  include SimpleEnum::Mongoid

  as_enum :mission, mission_1: 'mission_1', mission_2: 'mission_2'

  field :flight_time, type: String
  field :view_history, type: Mongoid::Boolean
  
  validates :view_history, presence: true

  belongs_to :user
  belongs_to :flying_log
end
