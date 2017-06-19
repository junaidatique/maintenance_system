class Notfication
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :notifiable, polymorphic: true

  
end
