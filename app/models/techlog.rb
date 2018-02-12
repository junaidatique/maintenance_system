class Techlog
  require 'autoinc'

  include Mongoid::Document
  include SimpleEnum::Mongoid
  include Mongoid::Autoinc

  as_enum :type, Flight: 0, Maintenance: 1, Scheduled: 2
  as_enum :condition, open: 0, interm: 2, completed: 1

  field :log_time, type: String
  field :log_date, type: Date
  field :number, type: Integer
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
  field :tools_used, type: String
  field :dms_version, type: String
  field :is_completed, type: Mongoid::Boolean, default: 0
  field :user_generated, type: Mongoid::Boolean, default: 0

  field :is_viewed, type: Mongoid::Boolean, default: 0

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

  
  attr_accessor :current_user

  validate :description_validation
  validate :flying_log_values
  validate :verify_complete
  validate :verify_interm

  def verify_interm
    if condition_cd == 2 and action.blank?
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
    if condition_cd == 1 and (tools_state == "requested" or tools_state == "provided") 
      errors.add(:status, " there are some tools that are not returned yet. ")
    elsif interm_log.present? and !interm_log.is_completed?
      errors.add(:status, " This techlog has an interm log. Please complete that log first. ")
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

  state_machine :parts_state, initial: :started, namespace: :'parts' do
    event :parts_requested do
      transition started: :requested
    end
    event :parts_provided do
      transition requested: :provided
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

  belongs_to :work_unit_code, optional: true
  belongs_to :flying_log, optional: true
  belongs_to :user
  belongs_to :aircraft, optional: true
  belongs_to :parent_techlog, class_name: Techlog.name, inverse_of: :interm_log, optional: true

  has_one :date_inspected, dependent: :destroy
  has_one :work_performed, dependent: :destroy
  has_one :work_duplicate, dependent: :destroy  
  has_one :interm_log, class_name: Techlog.name, inverse_of: :parent_techlog
  has_many :change_parts, dependent: :destroy
  has_many :assigned_tools, dependent: :destroy, inverse_of: :techlog

  embeds_many :techlog_state_transitions

  accepts_nested_attributes_for :work_performed
  accepts_nested_attributes_for :date_inspected
  accepts_nested_attributes_for :work_duplicate  
  accepts_nested_attributes_for :flying_log
  accepts_nested_attributes_for :change_parts
  accepts_nested_attributes_for :assigned_tools

  after_create :set_condition
  after_create :set_aircraft
  after_create :set_dms_version
  after_update :update_flying_log_end_time
  after_update :create_interm_log, if: Proc.new { |t_log| t_log.condition_cd == 2 }
  
  scope :techloged, -> { where(log_state: :techloged) }
  scope :addled, -> { where(log_state: :addled) }
  scope :limited, -> { where(log_state: :limited) }
  
  scope :completed, -> { where(condition_cd: 1) }
  scope :incomplete, -> { where(condition_cd: 0) }
  
  def is_completed?
    return condition_cd == 1 ? true : false
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

  def set_condition
    self.condition_cd = 0
    self.save
  end
  def set_dms_version
    self.dms_version = System.first.settings['dms_version_number'] 
    self.save
  end

  def update_flying_log_end_time
    if self.flying_log.present?
      if flying_log.techlogs.incomplete.count == 0
        flying_log.flightline_servicing.flight_end_time = Time.zone.now.strftime("%H:%M %p")
        flying_log.flightline_servicing.save!
      end
    end
  end
  
  def create_interm_log    
    if interm_log.blank?
      temp_interm_log = self.clone
      temp_interm_log.parent_techlog = self
      temp_interm_log.number = Techlog.last.number + 1
      temp_interm_log.description = self.action
      temp_interm_log.action = ''
      temp_interm_log.save
    end    
  end
end
