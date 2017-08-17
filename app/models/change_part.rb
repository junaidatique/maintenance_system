class ChangePart
  include Mongoid::Document

  belongs_to :old_part, class_name: 'Part'
  belongs_to :new_part, class_name: 'Part'

  belongs_to :techlog
end
