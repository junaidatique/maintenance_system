class FlyingHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  field :this_aircraft_hours, type: Float, default: 0
  field :total_aircraft_hours, type: Float, default: 0
  field :touch_go, type: Integer, default: 0
  field :full_stop, type: Integer, default: 0
  field :total_landings, type: Integer, default: 0
  field :this_engine_hours, type: Float, default: 0
  field :total_engine_hours, type: Float, default: 0
  field :this_prop_hours, type: Float, default: 0
  field :total_prop_hours, type: Float, default: 0
  field :remarks, type: String

  belongs_to :aircraft
  belongs_to :flying_log, optional: true

  after_create :create_landing_history
  after_update :create_landing_history

  def create_landing_history
    if flying_log.present?
      time = flying_log.created_at
      landings = flying_log.sortie.total_landings
      # record = LandingHistory.collection.aggregate([      
      #   {
      #     "$project" =>
      #       {           
      #         "year" => { "$year" => "$created_at" },
      #         "month" => { "$month" => "$created_at" },
      #         "day" => { "$dayOfMonth" => "$created_at" },
      #         "aircraft_id" => 1,
      #         "left_tyre_id" => 1,
      #         "right_tyre_id" => 1,
      #         "nose_tail_id" => 1
      #       }
      #   },
      #   {
      #     "$match" =>
      #     {
      #       "year"=>  time.utc.strftime("%Y").to_i, 
      #       "month"=> time.utc.strftime("%m").to_i, 
      #       "day"=> time.utc.strftime("%d").to_i, 
      #       "aircraft_id"=> aircraft.id, 
      #       "left_tyre_id"=> aircraft.part_items.left_tyres.first.id,
      #       "right_tyre_id"=> aircraft.part_items.right_tyres.first.id,
      #       "nose_tail_id"=> aircraft.part_items.nose_tails.first.id
      #     }
      #   }        
      # ])
      history = LandingHistory.where(flying_log_id: self.id).first      
      if history.present?
        left_tyre_total_landings    = history.left_tyre_total_landings - landings
        right_tyre_total_landings   = history.right_tyre_total_landings - landings
        nose_tail_total_landings    = history.nose_tail_total_landings - landings
      else
        history = LandingHistory.new if history.blank?
        left_tyre_total_landings    = flying_log.left_tyre.landings_completed - landings
        right_tyre_total_landings   = flying_log.right_tyre.landings_completed - landings
        nose_tail_total_landings    = flying_log.nose_tail.landings_completed - landings
      end
      history.aircraft = aircraft
      history.flying_log = flying_log
      history.left_tyre_id = flying_log.left_tyre.id
      history.right_tyre_id = flying_log.right_tyre.id
      history.nose_tail_id = flying_log.nose_tail.id        
      history.created_at = time
      history.left_tyre_landings   = landings
      history.right_tyre_landings  = landings
      history.nose_tail_landings   = landings
      history.left_tyre_total_landings   = left_tyre_total_landings + landings
      history.right_tyre_total_landings  = right_tyre_total_landings + landings
      history.nose_tail_total_landings   = nose_tail_total_landings + landings
      history.save!


        
      #   right_tyre_total_landings = 0
      #   nose_tail_total_landings  = 0
      #   if last_history.left_tyre.id == aircraft.part_items.left_tyres.first.id
      #     left_tyre_total_landings  = last_history.left_tyre_total_landings
      #   end
      #   if last_history.right_tyre.id == aircraft.part_items.right_tyre.first.id
      #     right_tyre_total_landings  = last_history.right_tyre_total_landings
      #   end
      #   if last_history.nose_tail.id == aircraft.part_items.nose_tail.first.id
      #     nose_tail_total_landings  = last_history.nose_tail_total_landings
      #   end

      #   if last_history.present?
          
          
      #   else
          
      #   end
      #   hist      = LandingHistory.new
        
      # else 
      #   hist = LandingHistory.find(record.first[:_id])
      #   left_tyre_total_landings  = history.left_tyre_total_landings.to_i
      #   right_tyre_total_landings = history.right_tyre_total_landings.to_i
      #   nose_tail_total_landings  = history.nose_tail_total_landings.to_i        
      # end
      # history.left_tyre_landings   = history.left_tyre_landings.to_i + landings
      # history.right_tyre_landings  = history.right_tyre_landings.to_i + landings
      # history.nose_tail_landings   = history.nose_tail_landings.to_i + landings
      # history.left_tyre_total_landings   = left_tyre_total_landings + landings
      # history.right_tyre_total_landings  = right_tyre_total_landings + landings
      # history.nose_tail_total_landings   = nose_tail_total_landings + landings
      # history.save!
    end
    
  end
end
