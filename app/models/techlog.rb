class Techlog
  require 'autoinc'

  include Mongoid::Document
  include SimpleEnum::Mongoid
  include Mongoid::Autoinc

  as_enum :type, flight: 0, maintenance: 1, scheduled: 2
  as_enum :log_status, techlog: 1, addl_log: 2, limitation_log: 3
  field :log_time, type: String
  field :number, type: Integer
  field :description, type: String
  field :action, type: String
  field :type, type: String
  field :additional_detail_form, type: Mongoid::Boolean, default: 0
  field :component_on_hold, type: Mongoid::Boolean, default: 0
  field :sap_notif, type: String
  field :sap_wo, type: String
  field :amr_no, type: String
  field :occurrence_report, type: String
  field :tools_used, type: String
  field :dms_version, type: String
  
  increments :number, seed: 1000


  before_create :set_as_techlog

  belongs_to :work_unit_code, optional: true
  belongs_to :flying_log
  belongs_to :user

  has_one :date_inspected
  has_one :work_performed
  has_one :work_duplicate
  has_many :change_parts

  accepts_nested_attributes_for :work_performed
  accepts_nested_attributes_for :date_inspected
  accepts_nested_attributes_for :work_duplicate
  accepts_nested_attributes_for :change_parts

  def set_as_techlog
    self.log_status = 1
  end
end
