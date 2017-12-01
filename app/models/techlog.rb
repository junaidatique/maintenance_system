class Techlog
  require 'autoinc'

  include Mongoid::Document
  include SimpleEnum::Mongoid
  include Mongoid::Autoinc

  as_enum :type, Flight: 0, Maintenance: 1, Scheduled: 2
  as_enum :condition, completed: 1, interm: 2, created: 0

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


  validates :description, presence: true
  validate :flying_log_values
  attr_accessor :current_user
  def flying_log_values
    if flying_log.present? and current_user.present? and current_user.role == :crew_cheif
      if flying_log.fuel_refill.blank?
        errors.add(:fuel_refill, "can't be in empty")
      end
    end
  end

  increments :number, seed: 1000

  state_machine initial: :techloged, namespace: :'log' do
    audit_trail initial: false
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

  belongs_to :work_unit_code
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

  after_create :set_aircraft
  after_update :update_flying_log_end_time

  scope :techloged, -> { where(state: :techloged) }
  scope :addled, -> { where(state: :addled) }
  scope :limited, -> { where(state: :limited) }
  
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
      if flying_log.techlogs.where(is_completed: false).count == 0
        flying_log.flightline_servicing.flight_end_time = Time.zone.now.strftime("%H:%M %p")
        flying_log.flightline_servicing.save!
      end
    end
  end
end