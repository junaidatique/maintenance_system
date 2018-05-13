class History
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :entry, type: String

  embedded_in :historyable, polymorphic: true
end
