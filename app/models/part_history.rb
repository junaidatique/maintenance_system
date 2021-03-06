class PartHistory
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :quantity, type: Float, default: 0
  field :hours, type: Float, default: 0
  field :total_hours, type: Float, default: 0
  field :landings, type: Integer, default: 0  
  field :total_landings, type: Integer, default: 0  

  belongs_to :part_item
  belongs_to :flying_log, optional: true
  belongs_to :techlog, optional: true
  belongs_to :aircraft, optional: true
  
end
