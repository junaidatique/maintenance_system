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

  def create_landing_history
    if flying_log.present?
      time = flying_log.created_at
      landings = flying_log.sortie.total_landings
      record = LandingHistory.collection.aggregate([      
        {
          "$project" =>
            {           
              "year" => { "$year" => "$created_at" },
              "month" => { "$month" => "$created_at" },
              "day" => { "$dayOfMonth" => "$created_at" },
              "aircraft_id" => 1,
              "left_tyre_id" => 1,
              "right_tyre_id" => 1,
              "nose_tail_id" => 1
            }
        },
        {
          "$match" =>
          {
            "year"=>  time.utc.strftime("%Y").to_i, 
            "month"=> time.utc.strftime("%m").to_i, 
            "day"=> time.utc.strftime("%d").to_i, 
            "aircraft_id"=> aircraft.id, 
            "left_tyre_id"=> aircraft.part_items.left_tyres.first.id,
            "right_tyre_id"=> aircraft.part_items.right_tyres.first.id,
            "nose_tail_id"=> aircraft.part_items.nose_tails.first.id
          }
        }        
      ])
      if record.count == 0
        last_hist = aircraft.landing_histories.last
        left_tyre_total_landings  = 0        
        right_tyre_total_landings = 0        
        nose_tail_total_landings  = 0        
        if last_hist.present?
          if last_hist.left_tyre.id == aircraft.part_items.left_tyres.first.id
            left_tyre_total_landings  = last_hist.left_tyre_total_landings
          end
          if last_hist.right_tyre.id == aircraft.part_items.right_tyre.first.id
            right_tyre_total_landings  = last_hist.right_tyre_total_landings
          end
          if last_hist.nose_tail.id == aircraft.part_items.nose_tail.first.id
            nose_tail_total_landings  = last_hist.nose_tail_total_landings
          end
        else
          left_tyre_total_landings  = aircraft.part_items.left_tyres.first.landings_completed
          right_tyre_total_landings  = aircraft.part_items.right_tyres.first.landings_completed
          nose_tail_total_landings  = aircraft.part_items.nose_tails.first.landings_completed
        end
        hist      = LandingHistory.new
        hist.aircraft = aircraft
        hist.left_tyre_id = aircraft.part_items.left_tyres.first.id
        hist.right_tyre_id = aircraft.part_items.right_tyres.first.id
        hist.nose_tail_id = aircraft.part_items.nose_tails.first.id        
        hist.created_at = time
      else 
        hist = LandingHistory.find(record.first[:_id])
        left_tyre_total_landings  = hist.left_tyre_total_landings.to_i
        right_tyre_total_landings = hist.right_tyre_total_landings.to_i
        nose_tail_total_landings  = hist.nose_tail_total_landings.to_i        
      end
      hist.left_tyre_landings   = hist.left_tyre_landings.to_i + landings
      hist.right_tyre_landings  = hist.right_tyre_landings.to_i + landings
      hist.nose_tail_landings   = hist.nose_tail_landings.to_i + landings
      hist.left_tyre_total_landings   = left_tyre_total_landings + landings
      hist.right_tyre_total_landings  = right_tyre_total_landings + landings
      hist.nose_tail_total_landings   = nose_tail_total_landings + landings
      hist.save!
    end
    
  end
end
