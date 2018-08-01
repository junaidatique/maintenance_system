class LandingHistory
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :left_tyre_landings, type: Integer, default: 0  
  field :left_tyre_total_landings, type: Integer, default: 0  
  field :right_tyre_landings, type: Integer, default: 0  
  field :right_tyre_total_landings, type: Integer, default: 0  
  field :nose_tail_landings, type: Integer, default: 0  
  field :nose_tail_total_landings, type: Integer, default: 0    

  belongs_to :left_tyre, class_name: 'Part', inverse_of: :left_tyre_histories 
  belongs_to :right_tyre, class_name: 'Part', inverse_of: :right_tyre_histories
  belongs_to :nose_tail, class_name: 'Part', inverse_of: :nose_tail_histories
  belongs_to :aircraft
  belongs_to :flying_log
  
  def self.create_record time, aircraft_id, landings
    
    # record = LandingHistory.collection.aggregate([      
    #   {
    #     "$project" =>
    #       {           
    #         "year" => { "$year" => "$created_at" },
    #         "month" => { "$month" => "$created_at" },
    #         "day" => { "$dayOfMonth" => "$created_at" },
    #         "aircraft_id" => 1,
    #         "left_tyre_id" => 1
    #         "right_tyre_id" => 1
    #         "nose_tail_id" => 1
    #       }
    #   },
    #   {
    #     "$match" =>
    #     {
    #       "year"=>  time.utc.strftime("%Y").to_i, 
    #       "month"=> time.utc.strftime("%m").to_i, 
    #       "day"=> time.utc.strftime("%d").to_i, 
    #       "aircraft_id"=> aircraft, 
    #       "left_tyre_id"=> part.id
    #     }
    #   }        
    # ])    
    # if record.count == 0
    #   hist = LandingHistory.new
    #   hist.aircraft_id = aircraft_id
    #   hist.part_id = part.id      
    #   hist.part_category_cd = part.category_cd      
    #   hist.created_at = time
    # else 
    #   hist = LandingHistory.find(record.first[:_id])
    #   landings = hist.landings.to_i + landings
    # end
    # hist.landings = landings
    # hist.save
    # puts time.strftime("%Y").inspect
    # puts time.strftime("%m").inspect
    # puts time.strftime("%d").inspect
    # puts record.inspect
    # puts record.count
    # puts record.first[:_id]

  end

end
