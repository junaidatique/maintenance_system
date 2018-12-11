class PartItemsController < ApplicationController
  before_action :set_part, only: [:show, :edit, :update, :destroy]

  # GET /parts
  # GET /parts.json
  def index
    @part_items = PartItem.all
    respond_to do |format|
      format.html
      format.csv { send_data @part_items.to_csv }
    end
    
    # format.html
    # format.csv { send_data @part_items.to_csv }
  end

  # GET /parts/1
  # GET /parts/1.json
  def show
  end

  # GET /parts/new
  def new
    @part = PartItem.new
  end

  # GET /parts/1/edit
  def edit
  end

  # POST /parts
  # POST /parts.json
  def create
    @part = PartItem.new(part_params)    
    respond_to do |format|
      if @PartItem.save
        format.html { redirect_to @part, notice: 'Part was successfully created.' }
        format.json { render :show, status: :created, location: @part }
      else
        format.html { render :new }
        format.json { render json: @PartItem.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parts/1
  # PATCH/PUT /parts/1.json
  def update
    respond_to do |format|
      if @PartItem.update(part_params)        
        format.html { redirect_to @part, notice: 'Part was successfully updated.' }
        format.json { render :show, status: :ok, location: @part }
      else
        format.html { render :edit }
        format.json { render json: @PartItem.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parts/1
  # DELETE /parts/1.json
  def destroy
    @PartItem.destroy
    respond_to do |format|
      format.html { redirect_to parts_url, notice: 'Part was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def upload
    @part = PartItem.new
  end

  def import
    PartItem.import(params[:file_excel])
    redirect_to parts_path, notice: 'Parts imported.'
  end

  # GET /parts/autocomplete_codes
  # GET /parts/autocomplete_codes.json
  def autocomplete    
    # search_string = params[:term]
    # aircraft_id   = params[:aircraft_id]
    # search_type   = params[:search_type]
    # record = PartItem.where(number: /.*#{search_string}.*/i)
    # record = record.any_of({aircraft_id: aircraft_id}, {serial_no: nil})
    # render :json => record.map { |part| 
    #   {
    #     id: PartItem.id.to_s, 
    #     label: "#{PartItem.number} #{PartItem.description}", 
    #     value: "#{PartItem.number}", 
    #   } 
    # }

    search_string = params[:term]
    record = PartItem.collection.aggregate([
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
        id: PartItem.where(number: part[:_id]).first.id.to_s, 
        label: "#{part[:_id]} (#{part[:name]})", 
        value: "#{part[:_id]}", 
      } 
    }
  end
  def autocomplete_serial
    search_string = params[:term]
    aircraft_id   = params[:aircraft_id]
    part_number   = params[:part_number]
    record        = PartItem.where(serial_no: /.*#{search_string}.*/i).where(number: part_number)
    puts record.inspect
    render :json => record.map { |part| 
      {
        id: PartItem.id.to_s, 
        label: "#{PartItem.serial_no}", 
        value: "#{PartItem.serial_no}", 
      } 
    }
  end
    
    
    
    
    # 
    # search_type = params[:search_type]
    # parts = PartItem.where(number: /.*#{search_string}.*/i)
    # if aircraft_id.present? 
    #   if search_type == 'include'
    #     parts = parts.where(aircraft_id: aircraft_id)
    #   else
    #     parts = parts.where(:aircraft_id.ne => aircraft_id)
    #   end
    # end
    # record = parts.limit(5)
    # render :json => record.map { |part| {id: PartItem._id.to_s, label: "#{PartItem.number_serial_no} (#{PartItem.quantity} left)", value: "#{PartItem.number_serial_no} (#{PartItem.quantity} left)" } }
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_part
      @part_item = PartItem.find(params[:id])
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
