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
    @part.create_history
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
        @part.create_history
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
    search_string = params[:term]
    aircraft_id = params[:aircraft_id]
    search_type = params[:search_type]
    parts = Part.where(number: /.*#{search_string}.*/i)
    if aircraft_id.present? 
      if search_type == 'include'
        parts = parts.where(aircraft_id: aircraft_id)
      else
        parts = parts.where(:aircraft_id.ne => aircraft_id)
      end
    end
    record = parts.limit(5)
    render :json => record.map { |part| {id: part._id.to_s, label: "#{part.number_serial_no} (#{part.quantity_left} left)", value: "#{part.number_serial_no} (#{part.quantity_left} left)" } }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_part
      @part = Part.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def part_params
      params.require(:part).permit(:aircraft_id,:number, :serial_no, :description, :unit_of_issue, :contract_quantity, :recieved_quantity, :quantity, :dfim_balance, :inspection_hours, :is_repairable, :condemn, :calender_life_value, :installed_date, :total_hours, :hours_completed)
    end
end
