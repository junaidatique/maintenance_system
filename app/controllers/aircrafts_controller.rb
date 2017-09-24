class AircraftsController < ApplicationController
  load_and_authorize_resource
  before_action :set_aircraft, only: [:show, :edit, :update, :destroy]
  

  # GET /aircrafts
  # GET /aircrafts.json
  def index
    @aircrafts = Aircraft.all
  end

  # GET /aircrafts/1
  # GET /aircrafts/1.json
  def show
  end

  # GET /aircrafts/new
  def new
    @aircraft = Aircraft.new
  end

  # GET /aircrafts/1/edit
  def edit
  end

  # POST /aircrafts
  # POST /aircrafts.json
  def create
    @aircraft = Aircraft.new(aircraft_params)

    respond_to do |format|
      if @aircraft.save
        format.html { redirect_to @aircraft, notice: 'Aircraft was successfully created.' }
        format.json { render :show, status: :created, location: @aircraft }
      else
        format.html { render :new }
        format.json { render json: @aircraft.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /aircrafts/1
  # PATCH/PUT /aircrafts/1.json
  def update
    respond_to do |format|
      if @aircraft.update(aircraft_params)
        format.html { redirect_to @aircraft, notice: 'Aircraft was successfully updated.' }
        format.json { render :show, status: :ok, location: @aircraft }
      else
        format.html { render :edit }
        format.json { render json: @aircraft.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /aircrafts/1
  # DELETE /aircrafts/1.json
  def destroy
    @aircraft.destroy
    respond_to do |format|
      format.html { redirect_to aircrafts_url, notice: 'Aircraft was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /aircrafts/get_aircrafts
  # GET /aircrafts/get_aircrafts.json
  def get_aircrafts
    search_string = params[:q]
    aircrafts = Aircraft.where(tail_number: /.*#{search_string}.*/i).limit(30)
    respond_to do |format|
      format.json { render json: { items: aircrafts.map { |a| { id: a.id.to_s, tail_number: a.tail_number } }, total_count: aircrafts.length, incomplete_results: false } }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_aircraft
      @aircraft = Aircraft.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def aircraft_params
      params.require(:aircraft).permit(:tail_number, :serial_no, :available_for_flight, :status,
                                      parts_attributes: [:id, :number, :noun, :serial_no, :calender_life, 
                                        :installed_date,  :remaining_hours, :flight_hours, :no_of_landings,
                                        :is_lifed, :_destroy])
    end
end
