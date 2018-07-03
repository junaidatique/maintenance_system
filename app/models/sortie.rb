class Sortie
  include Mongoid::Document
  include SimpleEnum::Mongoid
  include Mongoid::Timestamps

  as_enum :sortie_code, C1: 1, C2: 2, C3: 3, C4: 4, C5: 5
  as_enum :sortie_code_unsat, C2: 2, C3: 3, C4: 4, C5: 5
  as_enum :pilot_comment, Satisfactory: 'SAT', Un_satisfactory: 'Un Sat'
  field :takeoff_time, type: String
  field :landing_time, type: String
  field :flight_time, type: Float, default: 0 # tenth conversion table
  field :flight_minutes, type: String
  field :touch_go, type: String
  field :full_stop, type: String
  field :total_landings, type: Integer, default: 0   # to be calculated
  field :remarks, type: String
  

  validates :takeoff_time, presence: true
  validates :landing_time, presence: true
  validates :touch_go, presence: true
  validates :full_stop, presence: true
  validates :pilot_comment, presence: true

  belongs_to :user, optional: true
  belongs_to :flying_log
  

  def calculate_flight_minutes
    takeoff_time = DateTime.strptime(self.takeoff_time, '%H:%M %p')
    landing_time = DateTime.strptime(self.landing_time, '%H:%M %p')
    # ((DateTime.strptime((landing_time.to_i + 86400).to_s,'%s') - takeoff_time) * 24 * 60).to_i
    if landing_time < takeoff_time      
      landing_time = (DateTime.strptime((landing_time.to_i + 86400).to_s,'%s'))
    end
    ((landing_time - takeoff_time) * 24 * 60).to_i    
  end

  def calculate_landings
    total_landings = touch_go.to_i + full_stop.to_i
  end

  def calculate_flight_time
    hours = self.flight_minutes.to_i / 60
    mins  = self.flight_minutes.to_i % 60
    mins_to_table = 0
    case mins
    when 3..8
      mins_to_table = 1
    when 9..14
      mins_to_table = 2
    when 15..20
      mins_to_table = 3
    when 21..26
      mins_to_table = 4
    when 27..33
      mins_to_table = 5
    when 34..39
      mins_to_table = 6
    when 40..45
      mins_to_table = 7
    when 46..51
      mins_to_table = 8
    when 52..57
      mins_to_table = 9
    when 58..59
      hours = hours.to_i + 1
    end
    "#{hours}.#{mins_to_table}"
  end

  
end
