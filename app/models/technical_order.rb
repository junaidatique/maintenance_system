class TechnicalOrder
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :version_number, type: Float, default: 0.0
  field :name, type: String

  has_mongoid_attached_file :pdf_file
  validates_attachment_content_type :pdf_file, content_type: ['application/pdf']

  has_many :technical_changes, class_name: Change.name, inverse_of: :technical_order

  accepts_nested_attributes_for :technical_changes

  after_create :create_first_change 
  
  def create_first_change
    c = Change.new
    c.technical_order = self
    c.change_number = "First Release"
    c.pdf_file = self.pdf_file
    c.dms_version_number = 0
    c.change_date = Time.zone.now.strftime("%d-%m-%Y")
    c.save
  end

  
end
