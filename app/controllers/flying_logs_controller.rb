require 'combine_pdf'
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
    if FlyingPlan.where(is_flying: true).where(flying_date: Time.zone.now.strftime("%Y-%m-%d")).blank?
      redirect_to flying_logs_path, :flash => { :error => "Flying is not allowed for today." }
    end

    @flying_log = FlyingLog.new
    last_flying_log = FlyingLog.last
    if last_flying_log.present?
      @flying_log.number = last_flying_log.number + 1
    else
      @flying_log.number = 1001
    end
    @flying_log.build_ac_configuration 
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
    # TODO update this code for WUC of crewcheif
    if current_user.role == :crew_cheif
      inspection_performed = @flying_log.flightline_servicing.inspection_performed_cd
      wuc = WorkUnitCode.where(wuc_type_cd: inspection_performed).where(:id.in => current_user.work_unit_code_ids).first
      techlog = Techlog.where(flying_log: @flying_log, work_unit_code: wuc).first
      if !techlog.is_completed
        redirect_to techlog_path(techlog), :flash => { :error => "Please fill this techlog first." }
      end
    elsif Techlog.where(flying_log: @flying_log).incomplete.count > 0 and !@flying_log.pilot_commented?
      redirect_to flying_log_path(@flying_log), :flash => { :error => "Techlog for this Flying log are still not completed." }
    end
    
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
        puts @flying_log.flightline_service
        puts @flying_log.inspect

        format.html { redirect_to @flying_log, notice: 'Flying log was successfully created.' }
        format.json { render :show, status: :created, location: @flying_log }
      else
        last_flying_log = FlyingLog.last
        if last_flying_log.present?
          @flying_log.number = last_flying_log.number + 1
        else
          @flying_log.number = 1001
        end
        puts @flying_log.errors.inspect
        format.html { render :new }
        format.json { render json: @flying_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /flying_logs/1
  # PATCH/PUT /flying_logs/1.json
  def update
    respond_to do |format|      
      if current_user.role == :pilot and @flying_log.flight_booked? and flying_log_params[:sortie_attributes][:pilot_comment] == 'Satisfactory'
        update_params = flying_log_params.except(:techlogs_attributes)
      else
        update_params = flying_log_params
      end

      if @flying_log.update(update_params)
        if current_user.role == :master_control and @flying_log.fuel_filled?
          @flying_log.flight_release
        elsif current_user.role == :pilot and @flying_log.flight_released?
          @flying_log.book_flight
        elsif current_user.role == :pilot and @flying_log.flight_booked?
          
          @flying_log.sortie.total_landings = @flying_log.sortie.touch_go.to_i + @flying_log.sortie.full_stop.to_i
          @flying_log.sortie.flight_minutes = @flying_log.sortie.calculate_flight_minutes
          @flying_log.sortie.flight_time    = @flying_log.sortie.calculate_flight_time
          @flying_log.sortie.total_landings = @flying_log.sortie.calculate_landings
          @flying_log.sortie.update_aircraft_times
          @flying_log.sortie.save!
          @flying_log.pilot_back
        elsif (current_user.role == :master_control or current_user.role == :engineer or current_user.role == :admin) and @flying_log.pilot_commented?
          @flying_log.techlog_check
          if @flying_log.flightline_servicing.inspection_performed_cd != 2 and @flying_log.techlogs.incomplete.count == 0
            @flying_log.complete_log
          end

        elsif (current_user.role == :master_control or current_user.role == :admin) and @flying_log.pilot_commented?
          @flying_log.complete_log
        end
        
        @flying_log.save
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
    # techlogs  = @flying_log.techlogs.where(type_cd: 1).limit(3).offset(0)
    # pdf_data = render(
    #             pdf: "flying_log_#{@flying_log.id}",
    #             orientation: 'Landscape',
    #             template: 'flying_logs/flying_log_pdf.html.slim',
    #             layout: 'layouts/pdf/pdf.html.slim',
    #             show_as_html: false,
    #             locals: {
    #               flying_log: @flying_log,
    #               techlogs: techlogs
    #             },
    #             page_height: '17in',
    #             page_width: '13in',
    #             margin:  {
    #               top: 0,
    #               bottom: 0,
    #               left: 0,
    #               right:0 
    #             }
    #           )
            
      
    i = 0
    num = @flying_log.techlogs.where(type_cd: 1.to_s).count
    merged_certificates = CombinePDF.new
    
    begin
      techlogs  = @flying_log.techlogs.where(type_cd: 1.to_S).limit(3).offset(i)
      puts techlogs
      pdf_data = render_to_string(
                  pdf: "flying_log_#{@flying_log.id}",
                  orientation: 'Landscape',
                  template: 'flying_logs/flying_log_pdf.html.slim',
                  layout: 'layouts/pdf/pdf.html.slim',
                  show_as_html: false,
                  locals: {
                    flying_log: @flying_log,
                    techlogs: techlogs
                  },
                  page_height: '17in',
                  page_width: '13in',
                  margin:  {
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right:0 
                  }
                )
              
      merged_certificates  << CombinePDF.parse(pdf_data)
      i +=3  
    end while i < num
    send_data merged_certificates.to_pdf, :disposition => 'inline', :type => "application/pdf"

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flying_log
      @flying_log = FlyingLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def flying_log_params
      unless params[:flying_log].blank?
         params.require(:flying_log).permit(:log_date, :aircraft_id, :location_from, :location_to,
                                ac_configuration_attributes: [:clean, :smoke_pods, :third_seat, :cockpit],
                                flightline_servicing_attributes: [:id, :inspection_performed, :flight_start_time, :flight_end_time, :user_id, :hyd, :_destroy],
                                capt_acceptance_certificate_attributes: [:flight_time, :view_history, :user_id, :mission],
                                sortie_attributes: [:user_id,:second_pilot_id, :third_seat_name, :takeoff_time, 
                                  :landing_time, :sortie_code, :touch_go, :pilot_comment, :full_stop, :sortie_code], 
                                capt_after_flight_attributes: [:flight_time, :user_id],
                                flightline_release_attributes: [:flight_time, :user_id],
                                techlogs_attributes: [:id, :work_unit_code_id, :user_id, :description, :type_cd, :_destroy],
                                after_flight_servicing_attributes: [:flight_time, :user_id, :oil_refill, :through_flight]
                                )
      end 
    end
end
