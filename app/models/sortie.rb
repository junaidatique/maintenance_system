class Sortie
  include Mongoid::Document
  include SimpleEnum::Mongoid

  validates :takeoff_time, presence: true
  validates :landing_time, presence: true
  validates :flight_time, presence: true
  validates :touch_go, presence: true
  validates :full_stop, presence: true
  validates :total, presence: true
  validates :remarks, presence: true
  validates :sortie_code, presence: true
    
  as_enum :sortie_code, C1: 1, C2: 2, C3: 3, C4: 4, C5: 5
  field :takeoff_time, type: String
  field :landing_time, type: String
  field :flight_time, type: String
  field :flight_minutes, type: String
  field :touch_go, type: String
  field :full_stop, type: String
  field :total, type: String
  field :remarks, type: String

  embeds_one :pilot_feedback, as: :attachable, class_name: Picture.name, cascade_callbacks: true, autobuild: true

  accepts_nested_attributes_for :pilot_feedback

  belongs_to :user, optional: true
  belongs_to :flying_log
end
