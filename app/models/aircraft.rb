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

  scope :active, -> { where(:id.in => FlyingPlan.where(is_flying: true).where(flying_date: Time.zone.now.strftime("%Y-%m-%d")).first.aircrafts.map(&:id)) }
  

  has_many :flying_logs, dependent: :destroy
  has_many :techlogs, dependent: :destroy
  has_many :parts, dependent: :destroy
  has_many :part_histories, dependent: :destroy
  has_many :scheduled_inspections, as: :inspectable

  accepts_nested_attributes_for :parts, :allow_destroy => true  
    
  def update_part_values flying_log
    self.flight_hours = flying_log.aircraft_total_time.corrected_total_aircraft_hours.to_f
    self.landings     = flying_log.aircraft_total_time.corrected_total_landings.to_f
    self.engine_hours = flying_log.aircraft_total_time.corrected_total_engine_hours.to_f
    self.prop_hours   = flying_log.aircraft_total_time.corrected_total_prop_hours.to_f
    self.save
    self.inspections.each do |inspection|
      inspection.first.update_scheduled_inspections self.flight_hours      
    end
    lifed_parts = self.parts.lifed    
    lifed_parts.each do |part|            
      part.create_history_with_flying_log flying_log
    end    
    tyre_parts = self.parts.tyre
    tyre_parts.each do |part|
      part.create_history_with_flying_log flying_log
    end
  end


end