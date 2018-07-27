class PartsController < ApplicationController
  before_action :set_part, only: [:show, :edit, :update, :destroy]

  # GET /parts
  # GET /parts.json
  def index
    @parts = Part.all
  end

  # GET /parts/1
  # GET /parts/1.json
  def show
  end

  # GET /parts/new
  def new
    @part = Part.new
  end

  # GET /parts/1/edit
  def edit
  end

  # POST /parts
  # POST /parts.json
  def create
    @part = Part.new(part_params)    
    respond_to do |format|
      if @part.save
        format.html { redirect_to @part, notice: 'Part was successfully created.' }
        format.json { render :show, status: :created, location: @part }
      else
        format.html { render :new }
        format.json { render json: @part.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parts/1
  # PATCH/PUT /parts/1.json
  def update
    respond_to do |format|
      if @part.update(part_params)        
        format.html { redirect_to @part, notice: 'Part was successfully updated.' }
        format.json { render :show, status: :ok, location: @part }
      else
        format.html { render :edit }
        format.json { render json: @part.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parts/1
  # DELETE /parts/1.json
  def destroy
    @part.destroy
    respond_to do |format|
      format.html { redirect_to parts_url, notice: 'Part was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def upload
    @part = Part.new
  end

  def import
    Part.import(params[:file_excel])
    redirect_to parts_path, notice: 'Parts imported.'
  end

  # GET /parts/autocomplete_codes
  # GET /parts/autocomplete_codes.json
  def autocomplete    
    # search_string = params[:term]
    # aircraft_id   = params[:aircraft_id]
    # search_type   = params[:search_type]
    # record = Part.where(number: /.*#{search_string}.*/i)
    # record = record.any_of({aircraft_id: aircraft_id}, {serial_no: nil})
    # render :json => record.map { |part| 
    #   {
    #     id: part.id.to_s, 
    #     label: "#{part.number} #{part.description}", 
    #     value: "#{part.number}", 
    #   } 
    # }

    search_string = params[:term]
    record = Part.collection.aggregate([
      {"$match"=>{"number"=>/#{search_string}.*/i}},
      {"$group" => {
          "_id" => "$number",
          "name" => { "$first": '$description' }, 
          "count" => {"$sum":1}
      }},
      {"$limit" => 5}
    ])    
    render :json => record.map { |part| 
      {
        id: Part.where(number: part[:_id]).first.id.to_s, 
        label: "#{part[:_id]} (#{part[:name]})", 
        value: "#{part[:_id]}", 
      } 
    }
  end
  def autocomplete_serial
    search_string = params[:term]
    aircraft_id   = params[:aircraft_id]
    part_number   = params[:part_number]
    record        = Part.where(serial_no: /.*#{search_string}.*/i).where(number: part_number)
    puts record.inspect
    render :json => record.map { |part| 
      {
        id: part.id.to_s, 
        label: "#{part.serial_no}", 
        value: "#{part.serial_no}", 
      } 
    }
  end
    
    
    
    
    # 
    # search_type = params[:search_type]
    # parts = Part.where(number: /.*#{search_string}.*/i)
    # if aircraft_id.present? 
    #   if search_type == 'include'
    #     parts = parts.where(aircraft_id: aircraft_id)
    #   else
    #     parts = parts.where(:aircraft_id.ne => aircraft_id)
    #   end
    # end
    # record = parts.limit(5)
    # render :json => record.map { |part| {id: part._id.to_s, label: "#{part.number_serial_no} (#{part.quantity} left)", value: "#{part.number_serial_no} (#{part.quantity} left)" } }
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_part
      @part = Part.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def part_params
      params.require(:part).permit(:aircraft_id, :category, :trade, :number, :serial_no, :description, :unit_of_issue, 
      :contract_quantity, :recieved_quantity, :quantity, :dfim_balance, 
      :is_repairable, :condemn, :is_lifed,
      :inspection_hours, :inspection_calender_value, 
      :calender_life_value, :total_hours,       
      :completed_hours, :installed_date, :landings_completed,
      :is_servicable)
    end
end
