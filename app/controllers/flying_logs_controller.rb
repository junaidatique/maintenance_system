class FlyingLogsController < ApplicationController
  before_action :set_flying_log, only: [:show, :edit, :update, :destroy]

  # GET /flying_logs
  # GET /flying_logs.json
  def index
    @flying_logs = FlyingLog.all
  end

  # GET /flying_logs/1
  # GET /flying_logs/1.json
  def show
  end

  # GET /flying_logs/new
  def new
    @flying_log = FlyingLog.new
    @flying_log.build_ac_configuration
    @flying_log.build_fuel
    @flying_log.build_capt_acceptance_certificate
    @flying_log.build_sortie
    @flying_log.build_capt_after_flight
    
  end

  # GET /flying_logs/1/edit
  def edit
  end

  # POST /flying_logs
  # POST /flying_logs.json
  def create
    @flying_log = FlyingLog.new(flying_log_params)

    respond_to do |format|
      if @flying_log.save
        format.html { redirect_to @flying_log, notice: 'Flying log was successfully created.' }
        format.json { render :show, status: :created, location: @flying_log }
      else
        format.html { render :new }
        format.json { render json: @flying_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /flying_logs/1
  # PATCH/PUT /flying_logs/1.json
  def update
    respond_to do |format|
      if @flying_log.update(flying_log_params)
        format.html { redirect_to @flying_log, notice: 'Flying log was successfully updated.' }
        format.json { render :show, status: :ok, location: @flying_log }
      else
        format.html { render :edit }
        format.json { render json: @flying_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /flying_logs/1
  # DELETE /flying_logs/1.json
  def destroy
    @flying_log.destroy
    respond_to do |format|
      format.html { redirect_to flying_logs_url, notice: 'Flying log was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flying_log
      @flying_log = FlyingLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def flying_log_params
      params.require(:flying_log).permit(:number, :log_date, :aircraft_id, :location_id, 
                                flightline_servicings_attributes: [:inspection_performed, :flightline_time, :user_id, :oil_refill])
    end
end
