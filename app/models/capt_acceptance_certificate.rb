class CaptAcceptanceCertificate
  include Mongoid::Document

  field :flight_time, type: String
  field :view_history, type: Mongoid::Boolean

  validates :view_history, presence: true

  belongs_to :user
  belongs_to :flying_log
end
