class Techlog
  require 'autoinc'

  include Mongoid::Document
  include SimpleEnum::Mongoid
  include Mongoid::Autoinc
  include Mongoid::Timestamps
  
  as_enum :type, Flight: 0, Maintenance: 1, Scheduled: 2, Tool: 3
  as_enum :new_type_values, Maintenance: 1, Tool: 3
  as_enum :condition, open: 0, interm: 2, completed: 1

  field :log_time, type: String
  field :log_date, type: Date
  field :number, type: Integer
  field :serial_no, type: String
  field :location_from, type: String
  field :location_to, type: String
  field :description, type: String
  field :action, type: String
  field :additional_detail_form, type: Mongoid::Boolean, default: 0
  field :nmcs_pmcs, type: Mongoid::Boolean, default: 0
  field :demand_notif, type: String
  field :amf_reference_no, type: String
  field :pdr_number, type: String  
  field :occurrence_report, type: String
  # field :tools_used, type: String
  field :dms_version, type: String
  field :is_completed, type: Mongoid::Boolean, default: 0
  field :user_generated, type: Mongoid::Boolean, default: 0

  field :is_viewed, type: Mongoid::Boolean, default: 0
  field :is_extention_applied, type: Mongoid::Boolean, default: 0
  field :is_extention_granted, type: Mongoid::Boolean, default: 0

  # ADDL
  field :addl_period_of_deferm, type: String
  field :addl_due, type: String
  field :addl_log_date, type: Date
  field :addl_log_time, type: String

  # Limitation Log
  field :limitation_description, type: String
  field :limitation_period_of_deferm, type: String
  field :limitation_due, type: String
  field :limitation_log_date, type: Date
  field :limitation_log_time, type: String
  field :verified_tools, type: Mongoid::Boolean
  
  attr_accessor :current_user


  belongs_to :scheduled_inspection, optional: true
  belongs_to :work_unit_code, optional: true
  belongs_to :autherization_code, optional: true
  belongs_to :flying_log, optional: true
  belongs_to :user, class_name: User.name, inverse_of: :techlogs
  belongs_to :closed_by, class_name: User.name, inverse_of: :closed_techlogs, optional: true  
  belongs_to :aircraft, optional: true
  belongs_to :parent_techlog, class_name: Techlog.name, inverse_of: :interm_logs, optional: true

  has_one :date_inspected, dependent: :destroy
  has_one :work_performed, dependent: :destroy
  has_one :work_duplicate, dependent: :destroy  
  has_many :interm_logs, class_name: Techlog.name, inverse_of: :parent_techlog
  has_many :change_parts, dependent: :destroy
  has_many :requested_tools, dependent: :destroy

  embeds_many :techlog_state_transitions

  accepts_nested_attributes_for :work_performed
  accepts_nested_attributes_for :date_inspected
  accepts_nested_attributes_for :work_duplicate  
  accepts_nested_attributes_for :flying_log
  accepts_nested_attributes_for :change_parts
  accepts_nested_attributes_for :requested_tools

  before_create :set_condition  
  after_create :create_serial_no    
  after_create :set_aircraft
  after_create :set_dms_version
  after_update :update_flying_log_end_time
  after_update :update_change_parts
  after_update :create_interm_log, if: Proc.new { |t_log| t_log.condition_cd == 2 }
  after_update :check_schedule_inspection, if: Proc.new { |t_log| t_log.condition_cd == 1 }
  
  scope :techloged, -> { where(log_state: :techloged) }
  scope :addled, -> { where(log_state: :addled) }
  scope :limited, -> { where(log_state: :limited) }  
  scope :completed, -> { where(condition_cd: 1) }
  scope :incomplete, -> { where(condition_cd: 0) }  
  scope :open, -> { any_of({condition_cd: 0}, {condition_cd: 2},{condition_cd: 0.to_s}, {condition_cd: 2.to_s})}
  scope :pilot_created, -> { any_of({type_cd: 1}, {type_cd: 1.to_s})}
  scope :flight_created, -> { any_of({type_cd: 0}, {type_cd: 0.to_s})}

  validates :type_cd, presence: true  
  validate :description_validation
  validate :flying_log_values
  validate :verify_complete
  validate :verify_interm
  validate :maintenance_work_unit_code


  def maintenance_work_unit_code        
    if type == :Maintenance and flying_log.blank? and autherization_code.blank?  
      errors.add(:autherization_code, " can't be blank")
    end
  end

  def verify_interm
    if (condition == :interm and action.blank?) or (condition == :completed and action.blank?)
      errors.add(:action, " can't be blank")
    end    
  end

  def flying_log_values
    if flying_log.present? and current_user.present? and current_user.role == :crew_cheif
      if flying_log.fuel_refill.blank?
        errors.add(:fuel_refill, "can't be empty")
      end
    end
  end

  def description_validation
    if flying_log.blank? or (flying_log.present? and flying_log.sortie.present? and flying_log.sortie.pilot_comment == 'Un_satisfactory')
      if description.blank?
        errors.add(:description, "can't be empty")
      end
    end
  end

  def verify_complete
    if condition == :completed and (parts_state == "requested" or parts_state == "pending" or parts_state == "not_available")
      errors.add(:status, " Some parts are missing. ")
    elsif condition == :completed and interm_logs.count > 0 and interm_logs.incomplete.count > 0
      errors.add(:status, " This techlog has interm log(s). Please complete that log first. ")
    end
    if condition == :completed and verified_tools.blank?      
      errors.add(:verified_tools, "Please verify that you have verified all the tools.")
    end
    if condition == :completed and type_cd == 3
      if self.requested_tools.where(is_returned: false).count > 0
        errors.add(:verified_tools, "Please return all tools.")
      end
    end    
  end

  increments :number, seed: 1000
  
  state_machine :log_state, initial: :techloged, namespace: :'log' do    
    event :change_to_addl do
      transition techloged: :addled
    end
    event :add_to_limitation do
      transition techloged: :limited
    end
    event :back_to_techlog do
      transition [:addled, :limited] => :techloged
    end
  end
  # For now
  # request part
  # provide part
  # if not available then request
  # request completed mark as avaiable
  # once required and provided quantity are same lets not edit it.
  
  state_machine :parts_state, initial: :started, namespace: :'parts' do
    event :parts_requested do
      transition started: :requested
    end
    event :parts_provided do
      transition [:requested, :pending, :not_available] => :provided
    end
    event :parts_pending do
      transition requested: :pending
    end
    event :parts_not_available do
      transition [:requested, :pending] => :not_available
    end
    event :parts_available do
      transition not_available: :provided
    end
  end
  state_machine :tools_state, initial: :started, namespace: :'tools' do
    event :tools_requested do
      transition started: :requested
    end
    event :tools_provided do
      transition requested: :provided
    end
    event :tools_returned do
      transition provided: :returned
    end    
  end  

  def set_condition
    self.condition_cd = self.condition_cd.to_i
    self.type_cd = self.type_cd.to_i
  end

  def create_serial_no
    ser = "#{Time.zone.now.strftime('%d%m%Y')}-#{number}"
    if self.aircraft.present?
      ser = "#{ser}-#{self.aircraft.tail_number}"
    end
    if self.autherization_code.present?
      ser = "#{ser}-#{self.autherization_code.autherized_trade.downcase}-#{self.autherization_code.type.downcase}"
    end
    self.serial_no = ser
    self.save
  end

  def set_aircraft
    if self.flying_log.present?
      self.aircraft_id    = self.flying_log.aircraft_id
      self.location_from  = self.flying_log.location_from
      self.location_to    = self.flying_log.location_to
      self.log_date       = Time.zone.now.strftime("%Y-%m-%d")
      self.log_time       = Time.zone.now.strftime("%H:%M %p")
      self.save
    end
  end

  def set_dms_version
    self.dms_version = System.first.settings['dms_version_number'] 
    self.save
  end

  def update_change_parts
    if change_parts.count > 0
      change_parts.each do |change_part|
        change_part.update_parts_quantity
      end
    end
  end

  def update_flying_log_end_time
    if self.flying_log.present?
      if flying_log.techlogs.techloged.flight_created.incomplete.count == 0                
        flying_log.flightline_servicing.flight_end_time = Time.zone.now
        flying_log.flightline_servicing.save
        flying_log.complete_servicing  
        if flying_log.flightline_servicing.inspection_performed_cd == 2
          flying_log.complete_post_flight
        end    
      end
    end
  end
  
  def create_interm_log    
    if interm_logs.blank? and scheduled_inspection_id.blank?
      temp_interm_log = self.clone
      temp_interm_log.parent_techlog = self
      temp_interm_log.number = Techlog.last.number + 1
      temp_interm_log.description = self.action
      temp_interm_log.location_from = self.location_from
      temp_interm_log.location_to = self.location_to
      temp_interm_log.condition_cd = 0
      temp_interm_log.action = ''
      temp_interm_log.user = self.closed_by      
      temp_interm_log.autherization_code = nil
      temp_interm_log.save!
    end    
  end

  def check_schedule_inspection
    if parent_techlog.present? 
      if parent_techlog.scheduled_inspection.present?
        if parent_techlog.interm_logs.incomplete.count == 0
          parent_techlog.condition_cd = 1
          parent_techlog.verified_tools = true
          parent_techlog.save
          parent_techlog.scheduled_inspection.complete_inspection
        end
      else
        parent_techlog.condition_cd = 1
        parent_techlog.save
      end
    end
  end
  
end
