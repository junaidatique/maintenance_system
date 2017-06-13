class Sortie
  include Mongoid::Document
  include SimpleEnum::Mongoid
  
  as_enum :sortie_code, C1: 1, C2: 2, C3: 3, C4: 4, C5: 5
  field :takeoff_time, type: String
  field :landing_time, type: String
  field :flight_time, type: String
  field :flight_minutes, type: String
  field :touch_go, type: String
  field :full_stop, type: String
  field :total, type: String
  field :remarks, type: String


  belongs_to :user
  belongs_to :flying_log
end
