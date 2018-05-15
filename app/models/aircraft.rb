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

  
  # scope :available, -> { where(:id.nin => Techlog.incomplete.distinct(:aircraft_id)) }
  scope :active, -> { where(:id.in => FlyingPlan.where(is_flying: true).where(flying_date: Time.zone.now.strftime("%Y-%m-%d")).first.aircrafts.map(&:id)) }
  

  has_many :flying_logs
  has_many :techlogs
  has_many :parts

  accepts_nested_attributes_for :parts, :allow_destroy => true
    
  def update_part_values flying_log
    self.flight_hours = self.flight_hours.to_f + flying_log.aircraft_total_time.this_sortie_aircraft_hours.to_f
    self.landings     = self.landings.to_f + flying_log.aircraft_total_time.this_sortie_landings.to_f
    self.engine_hours = self.engine_hours.to_f + flying_log.aircraft_total_time.this_sortie_engine_hours.to_f
    self.prop_hours   = self.prop_hours.to_f + flying_log.aircraft_total_time.this_sortie_prop_hours.to_f
    self.save
    hours_parts = self.parts.gt(total_hours: 0)
    hours_parts.each do |part|
      part_hours = part.hours_completed.to_f + hours.to_f
      part_remaining_hours = part.total_hours.to_f - part_hours
      part.update({hours_completed: part_hours, remaining_hours: part_remaining_hours})
      part.create_history
    end
    hours_parts = self.parts.gt(total_landings: 0)
    hours_parts.each do |part|
      part_landings = part.landings_completed.to_f + landings.to_f
      part_remaining_landings = part.total_landings.to_f - part_landings
      part.update({landings_completed: part_landings, landings_remaining: part_remaining_landings})
      part.create_history
    end

  end

end