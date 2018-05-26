class RequestedTool
  include Mongoid::Document
  include Mongoid::Timestamps

  field :tool_no, type: String
  field :quantity_required, type: Integer
  field :is_returned, type: Mongoid::Boolean, default: 0
  field :is_assigned, type: Mongoid::Boolean, default: 0

  validate :verify_quantity_requested  

  def verify_quantity_requested        
    if Tool.where(number: tool_no).count == 0
      errors.add(:tool_no, " is invalid.")
    end
    if quantity_required.blank?
      errors.add(:quantity_required, " is invalid.")
    end
    if quantity_required.present?
      unless RequestedTool.where(tool_no: tool_no).map{|req| req.techlog.id}.include? self.techlog.id
        if quantity_required > Tool.where(number: tool_no).gt(quantity_in_hand: 0).count
          errors.add(:quantity_required, " is not avialable.")
        end
      end
    end
  end

  belongs_to :techlog, optional: true  
  belongs_to :requested_by, :class_name => "User", optional: true

  has_many :assigned_tools, dependent: :destroy

  accepts_nested_attributes_for :assigned_tools

  after_create :create_assigned_tools

  scope :requested, -> { where(is_returned: false) }

  def create_assigned_tools
    (1..quantity_required).each do |assigned_tool|
      AssignedTool.create({requested_tool: self})
      # assigned_tool.requested_tool = self      
      # assigned_tool.save
    end
  end

end
