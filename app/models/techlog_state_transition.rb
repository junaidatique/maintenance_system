class TechlogStateTransition
  include Mongoid::Document
  include Mongoid::Timestamps
  field :namespace, type: String
  field :event, type: String
  field :from, type: String
  field :to, type: String
  #field :created_at, type: Timestamp
  embedded_in :techlog
end
