class FlyingPlan
  include Mongoid::Document
  include Mongoid::Timestamps

  field :flying_date, type: Date
  field :reason, type: String
  field :is_flying, type: Mongoid::Boolean

  has_and_belongs_to_many :aircrafts

  validate :due_inspections
  def due_inspections    
    due_inspection = nil
    aircrafts.each do |aircraft|
      aircraft.check_inspections
      if aircraft.scheduled_inspections.due.count > 0
        due_inspection = aircraft
      end
      if aircraft.parts.map{|part| part if part.scheduled_inspections.due.count > 0}.reject(&:blank?).count > 0
        due_inspection = aircraft
      end
    end
    
    if due_inspection.present?
      errors.add(:flying_date, " #{due_inspection.tail_number} has due inspections.")
    end
  end
end
