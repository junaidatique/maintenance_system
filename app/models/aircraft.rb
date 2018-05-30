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
  

  has_many :flying_logs
  has_many :techlogs
  has_many :parts
  has_many :part_histories
  has_many :inspections

  accepts_nested_attributes_for :parts, :allow_destroy => true

  after_create :create_inspections
    
  def update_part_values flying_log
    self.flight_hours = flying_log.aircraft_total_time.corrected_total_aircraft_hours.to_f
    self.landings     = flying_log.aircraft_total_time.corrected_total_landings.to_f
    self.engine_hours = flying_log.aircraft_total_time.corrected_total_engine_hours.to_f
    self.prop_hours   = flying_log.aircraft_total_time.corrected_total_prop_hours.to_f
    self.save
    self.inspections.each do |inspection|
      inspection.scheduled_inspections.gt(hours: 0).update_all({completed_hours: self.flight_hours})
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

  def create_inspections
    inspections = [
      {aircraft_id: self.id, name: 'Weekly', no_of_hours: 0, calender_value: 6, calender_unit: 'day'},
      {aircraft_id: self.id, name: '25 HRS', no_of_hours: '25'}, 
      {aircraft_id: self.id, name: '50 HRS', no_of_hours: '50', calender_value: 6, calender_unit: 'month'},
      {aircraft_id: self.id, name: '100 HRS', no_of_hours: '100', calender_value: 1, calender_unit: 'year'},
      {aircraft_id: self.id, name: '400 HRS', no_of_hours: '400'},
    ]
    Inspection.create!(inspections)

  end

end