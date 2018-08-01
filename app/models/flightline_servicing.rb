class FlightlineServicing
  include Mongoid::Document
  include SimpleEnum::Mongoid
  include Mongoid::Timestamps

  as_enum :inspection_performed, Preflight: 0, Thru_Flight: 1, Post_Flight: 2
  field :flight_start_time, type: String
  field :flight_end_time, type: String
  field :hyd, type: String

  validates :inspection_performed, presence: true
  # validate :check_flying_logs

  def check_flying_logs   
    puts '------------------------'
    puts self.inspect     
    puts '------------------------'
    if self.flying_log.aircraft.flying_logs.not_completed.map{|fl| (fl.flightline_servicing.inspection_performed_cd == inspection_performed_cd) ? 1 : 0}.sum > 0
      errors.add(:aircraft_id, " flying log already created")
    end
    
  end

  belongs_to :user
  belongs_to :flying_log
end
