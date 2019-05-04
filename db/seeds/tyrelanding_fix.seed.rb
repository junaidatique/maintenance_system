
#rails db:seed:tyrelanding_fix
LandingHistory.destroy_all
# aircraft = Aircraft.first
flying_logs = FlyingLog.ne(right_tyre_id: nil).order(created_at: :asc)
flying_logs.each do |flying_log|  
  flying_log.right_tyre.create_history_with_flying_log flying_log
  flying_log.left_tyre.create_history_with_flying_log flying_log
  flying_log.nose_tail.create_history_with_flying_log flying_log
  h = flying_log.flying_history
  h.create_landing_history
  print '.'
end

