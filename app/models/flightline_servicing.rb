class FlightlineServicing
  include Mongoid::Document
  include SimpleEnum::Mongoid
  include Mongoid::Timestamps

  as_enum :inspection_performed, Preflight: 0, Thru_Flight: 1, Post_Flight: 2
  field :flight_start_time, type: String
  field :flight_end_time, type: String
  field :hyd, type: String

  validates :inspection_performed, presence: true

  belongs_to :user
  belongs_to :flying_log
end
