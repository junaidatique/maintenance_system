class Picture
  include Mongoid::Document
  include Mongoid::Paperclip

  embedded_in :attachable, polymorphic: true

  has_mongoid_attached_file :attachment,
    :styles => {
      :original => ['1920x1680>', :jpg],
      :small    => ['100x100#',   :jpg],
      :medium   => ['250x250',    :jpg],
      :large    => ['500x500>',   :jpg],
      :thumb    => ['40x40',      :jpg]
    }
  validates_attachment_content_type :attachment,
    :content_type => ['image/png', 'image/jpeg', 'image/jpg'],
    :message => "Sorry, your attachment type is not recognized"
end
