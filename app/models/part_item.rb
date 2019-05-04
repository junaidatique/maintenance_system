class PartItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid
  
  as_enum :category, 
    engine: 0, 
    propeller: 1, 
    left_tyre: 2, 
    right_tyre: 3, 
    nose_tail: 4,
    battery: 5

  field :serial_no, type: String
  field :number_serial_no, type: String
  field :location, type: String

  # field :dfim_balance, type: Mongoid::Boolean
  # field :condemn, type: String
  
  field :is_servicable, type: Mongoid::Boolean, default: true

  field :installed_date, type: Date # this is the first installation date of this part on any aircraft
  field :manufacturing_date, type: Date # this is the date when part was manufactured.

  field :remaining_hours, type: Float, default: 0
  field :completed_hours, type: Float, default: 0  
  field :landings_completed, type: Integer, default: 0
  field :aircraft_installation_date, type: Date
  field :last_inspection_date, type: Date
  
  field :aircraft_referenced_lifed_hours, type: Float, default: 0
  field :aircraft_referenced_inspection_hours, type: Float, default: 0

  field :aircraft_installation_hours, type: Float, default: 0 #aircraft hours completed when part was installed on aircraft
  field :completed_hours_when_installed, type: Float, default: 0 #hours completed by part when installed on aircraft

  field :is_lifed, type: Mongoid::Boolean
  field :is_inspectable, type: Mongoid::Boolean
  
  

  belongs_to :aircraft, optional: true
  belongs_to :part

  has_many :fl_left_tyre, class_name: 'FlyingLog', inverse_of: :left_tyre
  has_many :fl_right_tyre, class_name: 'FlyingLog', inverse_of: :right_tyre  
  has_many :fl_nose_tail, class_name: 'FlyingLog', inverse_of: :nose_tail
  
  has_many :part_histories  
  has_many :old_parts, class_name: 'ChangePart', inverse_of: :old_parts
  has_many :new_parts, class_name: 'ChangePart', inverse_of: :new_parts  
  has_many :left_tyre_histories, class_name: 'LandingHistory', inverse_of: :left_tyre  
  has_many :right_tyre_histories, class_name: 'LandingHistory', inverse_of: :right_tyre  
  has_many :nose_tail_histories, class_name: 'LandingHistory', inverse_of: :nose_tail  
  has_many :scheduled_inspections, as: :inspectable

  scope :lifed, -> { where(is_lifed: true) }  
  scope :tyre, -> { any_of({category: :left_tyre}, {category: :right_tyre}, {category: :nose_tail})}
  scope :engine_part, -> { where(category: :engine)}
  scope :propeller_part, -> { where(category: :propeller)}
  scope :battery_part, -> { where(category_cd: 5)}
  scope :serviceables, -> { where(is_servicable: true)}
  scope :in_stock, -> { where(aircraft_id: nil)}
  
  validate :check_inspection_values

  before_create :set_part_n_record
  after_create :create_history
  after_create :check_inspections
  after_update :check_inspections
  
  def check_inspection_values
    if is_lifed?
      if part.track_from == :manufacturing_date and manufacturing_date.blank?
        errors.add(:part_item_id, " no manufacturing date provided.")
      end      
    end    
  end

  def set_part_n_record
    self.number_serial_no = "#{part.number}-#{serial_no}"
    self.is_lifed = self.part.is_lifed
    self.is_inspectable = self.part.is_inspectable    
    if (part.lifed_hours.present? and self.part.lifed_hours.to_f > 0)
      self.remaining_hours = (self.part.lifed_hours.to_f - completed_hours.to_f).round(2)      
      self.aircraft_referenced_lifed_hours = self.part.lifed_hours.to_f + self.aircraft_installation_hours.to_f - self.completed_hours_when_installed.to_f      
    end    
    
  end

  def create_history        
    part_history = PartHistory.new         
    part_history.quantity     = self.part.quantity
    part_history.hours        = self.completed_hours
    part_history.landings     = self.landings_completed
    part_history.flying_log   = nil
    part_history.aircraft_id  = self.aircraft.id if aircraft.present?
    part_history.created_at   = Time.zone.now
    part_history.part_item         = self      
    part_history.save
    
    part.system_quantity = part.part_items.serviceables.count
    part.quantity = part.part_items.serviceables.in_stock.count
    part.save
  end
  
  
  def check_inspections        
    if self.is_inspectable?
      part_inspections = Inspection.to_inspects.where(part_number: self.part.number)      
      part_inspections.each do |part_inspection|
        part_inspection.create_part_inspection self      
      end
    end
    if self.is_lifed?
      part_replacements = Inspection.to_replaces.where(part_number: self.part.number)
      part_replacements.each do |part_replacement|
        part_replacement.create_part_repalcement self if part_replacement.present?
      end
    end
    
  end

  def create_history_with_flying_log flying_log    
    if self.is_lifed?  or self.category == :right_tyre or self.category == :left_tyre or self.category == :nose_tail

      part_history = PartHistory.where(flying_log_id: flying_log.id).where(part_item_id: self.id).first
      if part_history.blank?      
        part_history = PartHistory.new         
        self.completed_hours = (self.completed_hours.to_f + flying_log.sortie.flight_time.to_f).round(2)
        self.landings_completed = self.landings_completed.to_i + flying_log.sortie.total_landings.to_i
      else 
        t_completed_hours = (self.completed_hours.to_f - part_history.hours.to_f).round(2)
        t_landings_completed = self.landings_completed.to_i - part_history.landings.to_i
        self.completed_hours = (t_completed_hours.to_f + flying_log.sortie.flight_time.to_f).round(2)
        self.landings_completed = t_landings_completed.to_i + flying_log.sortie.total_landings.to_i
      end
      self.remaining_hours     = (part.lifed_hours.to_f - completed_hours.to_f).round(2)      
      save
      
      part_history.quantity     = self.part.quantity
      part_history.hours        = flying_log.sortie.flight_time
      part_history.landings     = flying_log.sortie.total_landings
      part_history.flying_log   = flying_log
      part_history.aircraft_id  = flying_log.aircraft.id
      part_history.created_at   = flying_log.created_at
      part_history.total_hours    = part_histories.lt(flying_log_id: flying_log.id).sum('hours') + flying_log.sortie.flight_time
      part_history.total_landings = part_histories.lt(flying_log_id: flying_log.id).sum('landings') + flying_log.sortie.total_landings

      part_history.part_item         = self      
      part_history.save        
      # self.update_values      
      
      # self.scheduled_inspections.not_completed.each do |scheduled_inspection|
      #   scheduled_inspection.update_scheduled_inspections self.completed_hours      
      # end
    end    
  end

  def update_values
    # self.completed_hours     = part_histories.sum('hours').round(2)
    # self.landings_completed  = part_histories.sum('landings')
    # self.remaining_hours     = (total_hours.to_f - completed_hours.to_f).round(2)
    # save
    # self.scheduled_inspections.not_completed.inspection.first.update_scheduled_inspections self.completed_hours
    # self.scheduled_inspections.not_completed.each do |scheduled_inspection|
    #   scheduled_inspection.update_scheduled_inspections self.completed_hours      
    # end
  end

  def self.to_csv(options = {})
    fields = []    
    fields = PartItem.first.attributes.map{|k,v| k.to_s} + Part.first.attributes.map{|k,v| k.to_s}
    CSV.generate(options) do |csv|
      csv << fields
      all.each do |part_item|
        csv << (part_item.attributes.map{|k,v| v.to_s} + Part.find(part_item.part_id).attributes.map{|k,v| v.to_s} )
      end
    end
  end
  

  

  
end
