class CaptAcceptanceCertificate
  include Mongoid::Document

  field :flight_time, type: Time

  belongs_to :user
  belongs_to :flying_log
end
