class Aircraft
  include Mongoid::Document
  include Mongoid::Timestamps

  field :number, type: Integer
  field :tail_number, type: String
  field :serial_no, type: String
  
  field :fuel_capacity, type: Float, default: 0
  field :oil_capacity, type: Float, default: 0
  
  field :type_model, type: String
  field :type_series, type: String

  field :organization, type: String

  field :available_for_flight, type: Mongoid::Boolean
  
  field :flight_hours, type: Float, default: 0
  field :engine_hours, type: Float, default: 0
  field :prop_hours, type: Float, default: 0
  field :landings, type: Integer, default: 0


  validates :tail_number, presence: true
  validates :serial_no, presence: true
  validates :fuel_capacity, presence: true
  validates :oil_capacity, presence: true
  validates_uniqueness_of :tail_number

  
  scope :available, -> { where(:id.nin => Techlog.incomplete.distinct(:aircraft_id)) }
  scope :active, -> { where(:id.in => FlyingPlan.where(is_flying: true).where(flying_date: Time.zone.now.strftime("%Y-%m-%d")).first.aircrafts.map(&:id)) }
  

  has_many :flying_logs
  has_many :parts

  accepts_nested_attributes_for :parts, :allow_destroy => true
    
  def update_part_values flying_log
    hours = flying_log.aircraft_total_time.this_sortie_aircraft_hours
    landings = flying_log.aircraft_total_time.this_sortie_landings
    hours_parts = self.parts.gt(total_part_hours: 0)
    hours_parts.each do |part|
      part_hours = part.part_hours_completed.to_f + hours.to_f
      part_remaining_hours = part.total_part_hours.to_f - part_hours
      part.update({part_hours_completed: part_hours, remaining_hours: part_remaining_hours})
    end
    hours_parts = self.parts.gt(total_landings: 0)
    hours_parts.each do |part|
      part_landings = part.landings_completed.to_f + landings.to_f
      part_remaining_landings = part.total_landings.to_f - part_landings
      part.update({landings_completed: part_landings, landings_remaining: part_remaining_landings})
    end

  end

end