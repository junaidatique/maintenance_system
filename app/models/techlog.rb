class Techlog
  require 'autoinc'

  include Mongoid::Document
  include SimpleEnum::Mongoid
  include Mongoid::Autoinc

  as_enum :type, Flight: 0, Maintenance: 1, Scheduled: 2
  as_enum :condition, completed: 1, interm: 2, created: 0, field: { default: 1 }

  field :log_time, type: String
  field :log_date, type: Date
  field :number, type: Integer
  field :location_from, type: String
  field :location_to, type: String
  field :description, type: String
  field :action, type: String
  field :additional_detail_form, type: Mongoid::Boolean, default: 0
  field :component_on_hold, type: Mongoid::Boolean, default: 0
  field :sap_notif, type: String
  field :sap_wo, type: String
  field :amr_no, type: String
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


  # validates :description, presence: true
  validate :description_validation
  validate :flying_log_values
  attr_accessor :current_user
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

  increments :number, seed: 1000
  
  state_machine :log_state, initial: :techloged, namespace: :'log' do
    #audit_trail initial: false
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

  state_machine :status_state, initial: :started, namespace: :'status' do
    #audit_trail initial: false
    event :change_parts do
      transition started: :parts_demanded
    end
  end

  belongs_to :work_unit_code, optional: true
  belongs_to :flying_log, optional: true
  belongs_to :user
  belongs_to :aircraft, optional: true

  has_one :date_inspected, dependent: :destroy
  has_one :work_performed, dependent: :destroy
  has_one :work_duplicate, dependent: :destroy
  has_many :change_parts, dependent: :destroy

  embeds_many :techlog_state_transitions

  accepts_nested_attributes_for :work_performed
  accepts_nested_attributes_for :date_inspected
  accepts_nested_attributes_for :work_duplicate
  accepts_nested_attributes_for :change_parts
  accepts_nested_attributes_for :flying_log

  after_create :set_condition
  after_create :set_aircraft
  after_update :update_flying_log_end_time

  scope :techloged, -> { where(log_state: :techloged) }
  scope :addled, -> { where(log_state: :addled) }
  scope :limited, -> { where(log_state: :limited) }
  
  scope :completed, -> { where(is_completed: true) }
  scope :incomplete, -> { where(is_completed: false) }
  
  def is_completed?
    return is_completed ? true : false
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

  def update_flying_log_end_time
    if self.flying_log.present?
      if flying_log.techlogs.incomplete.count == 0
        flying_log.flightline_servicing.flight_end_time = Time.zone.now.strftime("%H:%M %p")
        flying_log.flightline_servicing.save!
      end
    end
  end
end
