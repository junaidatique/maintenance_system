class Change
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  embedded_in :technical_order, class_name: TechnicalOrder.name, inverse_of: :technical_changes

  field :change_number, type: String
  field :change_date, type: String

  has_mongoid_attached_file :pdf_file
  validates_attachment_content_type :pdf_file,
    :content_type => ['application/pdf']

  after_create :update_version_number

  def update_version_number
    self.technical_order.update! version_number: self.technical_order.version_number + 0.1
    system_ = System.first
    system_.update! settings: { dms_version_number: system_.settings[:dms_version_number] + 0.1}
  end
end
