class FlyingLogsController < ApplicationController
  before_action :set_flying_log, only: [:show, :edit, :update, :destroy, :pdf]

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
    last_flying_log = FlyingLog.last
    if last_flying_log.present?
      @flying_log.number = last_flying_log.number + 1
    else
      @flying_log.number = 1001
    end
    @flying_log.build_ac_configuration 
    @flying_log.build_fuel
    @flying_log.build_capt_acceptance_certificate
    @flying_log.build_sortie
    @flying_log.build_capt_after_flight
    @flying_log.build_flightline_release
    @flying_log.build_aircraft_total_time
    @flying_log.build_after_flight_servicing
    @flying_log.build_flightline_servicing


    @flying_log.log_date = Time.now.strftime("%d/%m/%Y")
    
  end

  # GET /flying_logs/1/edit
  def edit
    @flying_log.build_fuel if @flying_log.fuel.blank?
    @flying_log.build_capt_acceptance_certificate if @flying_log.capt_acceptance_certificate.blank?
    @flying_log.build_sortie if @flying_log.sortie.blank?
    @flying_log.build_capt_after_flight if @flying_log.capt_after_flight.blank?
    @flying_log.build_flightline_release if @flying_log.flightline_release.blank?
    @flying_log.build_aircraft_total_time if @flying_log.aircraft_total_time.blank?
    @flying_log.build_after_flight_servicing if @flying_log.after_flight_servicing.blank?
    
  end

  # POST /flying_logs
  # POST /flying_logs.json
  def create
    @flying_log = FlyingLog.new(flying_log_params)
    @flying_log.log_date = Time.now.strftime("%Y-%m-%d")
    respond_to do |format|
      if @flying_log.save
        format.html { redirect_to @flying_log, notice: 'Flying log was successfully created.' }
        format.json { render :show, status: :created, location: @flying_log }
      else
        last_flying_log = FlyingLog.last
        if last_flying_log.present?
          @flying_log.number = last_flying_log.number + 1
        else
          @flying_log.number = 1001
        end
        format.html { render :new }
        format.json { render json: @flying_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /flying_logs/1
  # PATCH/PUT /flying_logs/1.json
  def update
    respond_to do |format|
      if current_user.role == :crew_cheif and !@flying_log.is_fuel_filled
        @flying_log.is_fuel_filled = 1
      elsif current_user.role == :master_control and !@flying_log.is_flight_released
        @flying_log.is_flight_released = 1
      elsif current_user.role == :pilot and !@flying_log.is_flight_booked
        @flying_log.is_flight_booked = 1
      elsif current_user.role == :pilot and !@flying_log.is_pilot_back
        @flying_log.is_pilot_back = 1
      end
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

  # GET /flying_logs/1/pdf
  # GET /flying_logs/1/pdf.json
  def pdf
    render  pdf: "flying_log_#{@flying_log.id}",
      orientation: 'Landscape',
      template: 'flying_logs/flying_log_pdf.html.slim',
      layout: 'layouts/pdf/pdf.html.slim',
      show_as_html: false,
      locals: {
        :flying_log => @flying_log
      },
      page_height: '17in',
      page_width: '13in',
      margin:  {
        top: 0,                     # default 10 (mm)
        bottom: 0,
        left: 0,
        right:0 
      }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flying_log
      @flying_log = FlyingLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def flying_log_params
      params.require(:flying_log).permit(:log_date, :aircraft_id, :location_id,
                                ac_configuration_attributes: [:clean, :smoke_pods, :third_seat, :cockpit],
                                flightline_servicing_attributes: [:id, :inspection_performed, :flight_start_time, :flight_end_time, :user_id, :hyd, :_destroy],
                                fuel_attributes: [:fuel_remaining, :refill, :oil_remaining, :oil_serviced, :oil_total_qty],
                                capt_acceptance_certificate_attributes: [:flight_time, :user_id],
                                sortie_attributes: [:user_id, :takeoff_time, :landing_time, :flight_time, :sortie_code, :touch_go, :full_stop, :total, :remarks],
                                capt_after_flight_attributes: [:flight_time, :user_id],
                                flightline_release_attributes: [:flight_time, :user_id],
                                aircraft_total_time_attributes: [:carried_over_aircraft_hour, :carried_over_landings, :carried_over_ecs_operating_hour, 
                                  :this_sortie_aircraft_hour, :this_sortie_landings, :this_sortie_ecs_operating_hour, 
                                  :new_total_aircraft_hour, :new_total_landings, :new_total_ecs_operating_hour, 
                                  :correction_aircraft_hour, :correction_landings, :correction_ecs_operating_hour, 
                                  :corrected_total_aircraft_hour, :corrected_total_landings, :corrected_total_ecs_operating_hour],
                                techlogs_attributes: [:id, :log_time, :user_id, :description],
                                after_flight_servicing_attributes: [:flight_time, :user_id, :oil_refill, :through_flight]
                                )
    end
end
