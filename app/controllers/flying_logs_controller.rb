require 'combine_pdf'
class FlyingLogsController < ApplicationController  
  before_action :set_flying_log, only: [:show, :edit, :update, :destroy, :pdf, :cancel, :release, :update_timing]

  # GET /flying_logs
  # GET /flying_logs.json
  def index
    if current_user.admin?
      @flying_logs = FlyingLog.all
    else
      @flying_logs = FlyingLog.not_cancelled_not_completed.all
    end
    respond_to do |format|
      format.html
      format.js { render json: FlyingLogDatatable.new(view_context, current_user, @flying_logs)}
    end
    
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


    @flying_log.log_date = Time.zone.now.strftime("%d/%m/%Y")
    
  end

  # GET /flying_logs/1/edit
  def edit
    if @flying_log.flight_cancelled?
      redirect_to flying_log_path(@flying_log), :flash => { :error => "This Flying Log is cancelled." }
    end
    if @flying_log.aircraft.techlogs.techloged.incomplete.count > 0 and @flying_log.servicing_completed?
      redirect_to flying_log_path(@flying_log), :flash => { :error => "#{@flying_log.aircraft.tail_number} has some pending techlogs." }
    end
    
    # if current_user.role == :crew_cheif
    #   inspection_performed = @flying_log.flightline_servicing.inspection_performed_cd
    #   wuc = WorkUnitCode.where(wuc_type_cd: inspection_performed).where(:id.in => current_user.work_unit_code_ids).first
    #   techlog = Techlog.where(flying_log: @flying_log, work_unit_code: wuc).first
    #   if !techlog.is_completed
    #     redirect_to techlog_path(techlog), :flash => { :error => "Please fill this techlog first." }
    #   end
    # elsif Techlog.where(flying_log: @flying_log).incomplete.count > 0 and !@flying_log.logs_created?
    #   # redirect_to flying_log_path(@flying_log), :flash => { :error => "Techlog for this Flying log are still not completed." }
    # end
    
    @flying_log.build_capt_acceptance_certificate if @flying_log.capt_acceptance_certificate.blank?
    @flying_log.build_sortie if @flying_log.sortie.blank?
    @flying_log.build_capt_after_flight if @flying_log.capt_after_flight.blank?
    @flying_log.build_flightline_release if @flying_log.flightline_release.blank?
    @flying_log.build_aircraft_total_time if @flying_log.aircraft_total_time.blank?
    @flying_log.build_after_flight_servicing if @flying_log.after_flight_servicing.blank?
    @flying_log.build_post_mission_report if @flying_log.post_mission_report.blank?
    
    # merged_certificates = generate_pdf @flying_log
    # merged_certificates.save "#{@flying_log.serial_no}.pdf"
  end

  # POST /flying_logs
  # POST /flying_logs.json
  def create
    @flying_log = FlyingLog.new(flying_log_params)
    @flying_log.log_date = Time.zone.now.strftime("%Y-%m-%d")
    respond_to do |format|
      if @flying_log.save
        @flying_log.flightline_servicing.flight_start_time = Time.zone.now
        @flying_log.save
        @flying_log.flightline_service
        ActionCable.server.broadcast("log_channel", 
          message: "New Techlog is created for #{@flying_log.aircraft.tail_number}")
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
    redirect_page = @flying_log
    respond_to do |format|            
      begin
        if @flying_log.update!(flying_log_params)
          if can? :release_flight, FlyingLog and @flying_log.servicing_completed? and @flying_log.flightline_release.created_at.present?
            @flying_log.release_flight
          elsif current_user.pilot? and @flying_log.flight_released?
            if @flying_log.sortie.present?
              @flying_log.sortie.mission_cancelled    = false 
              @flying_log.sortie.remarks              = '' 
              @flying_log.post_mission_report.remarks = '' 
              @flying_log.save
            end
            
            @flying_log.book_flight
            ActionCable.server.broadcast("log_channel", 
            message: "#{@flying_log.aircraft.tail_number} is booked out.")
          elsif current_user.pilot? and @flying_log.flight_booked? 
            if @flying_log.sortie.mission_cancelled?
              @flying_log.sortie.remarks = @flying_log.post_mission_report.remarks
              @flying_log.back_to_release
            else            
              if @flying_log.sortie.pilot_comment_cd == "SAT"
                @flying_log.sortie.remarks = @flying_log.sortie.pilot_comment.to_s
                @flying_log.sortie.sortie_code_cd = 1
              end
              @flying_log.pilot_back!
            end
            redirect_page = edit_flying_log_path(@flying_log)
          elsif current_user.pilot? and @flying_log.pilot_commented? #and !@flying_log.sortie.mission_cancelled?
            @flying_log.pilot_confirmation
            if @flying_log.sortie.pilot_comment_cd == "SAT"
              @flying_log.sortie.remarks = @flying_log.sortie.pilot_comment.to_s
              @flying_log.sortie.sortie_code_cd = 1
              @flying_log.techlog_check
              @flying_log.techlogs.pilot_created.each do  |techlog|
                techlog.destroy
              end
              @flying_log.complete_log
            end      
          elsif can? :update_sortie, FlyingLog and @flying_log.pilot_confirmed?
            @flying_log.techlog_check
            @flying_log.complete_log          
          elsif can? :update_flying_hours, FlyingLog and @flying_log.log_completed?
            @flying_log.update_aircraft_times
          end

          
          @flying_log.save
          format.html { redirect_to redirect_page, notice: 'Flying log was successfully updated.' }
          format.json { render :show, status: :ok, location: @flying_log }
        else
          format.html { render :edit }
          format.json { render json: @flying_log.errors, status: :unprocessable_entity }        
        end
      rescue StandardError => e 
        format.html { render :edit }
        format.json { render json: e.message, status: :unprocessable_entity }        
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

  def generate_pdf flying_log
    i = 0
    num = flying_log.techlogs.where(type_cd: 1.to_s).count
    merged_certificates = CombinePDF.new
    
    begin
      techlogs  = flying_log.techlogs.where(type_cd: 1.to_s).limit(3).offset(i)
      pdf_data = render_to_string(
                  pdf: "flying_log_#{flying_log.id}",
                  orientation: 'Portrait',
                  template: 'flying_logs/flying_log_pdf.html.slim',
                  layout: 'layouts/pdf/pdf.html.slim',
                  show_as_html: false,
                  locals: {
                    flying_log: flying_log,
                    techlogs: techlogs
                  },
                  page_width: '15in',
                  page_height: '10in',
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
    return merged_certificates
  end

  # GET /flying_logs/1/pdf
  # GET /flying_logs/1/pdf.json
  def pdf      
    merged_certificates = generate_pdf @flying_log
    send_data merged_certificates.to_pdf, :disposition => 'inline', :type => "application/pdf"
  end

  def cancel
    @flying_log.cancel_flight
    redirect_to @flying_log
  end
  def release
    if @flying_log.flightline_serviced?
      @flying_log.fill_fuel
    elsif @flying_log.fuel_filled?
      @flying_log.complete_servicing
    elsif @flying_log.servicing_completed?
      @flying_log.release_flight
    end
    redirect_to @flying_log
  end
  def update_timing
    @flying_log.update_timing
    redirect_to edit_flying_log_path @flying_log
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
                                ac_configuration_attributes: [:clean, :smoke_pods, :third_seat, :cockpit, :smoke_oil_quantity],
                                flightline_servicing_attributes: [:id, :inspection_performed, :user_id, :hyd, :_destroy],
                                capt_acceptance_certificate_attributes: [:flight_time,:second_pilot_id, :third_seat_name, :view_history, :view_deffered_log, :user_id, :mission],
                                sortie_attributes: [:user_id, :takeoff_time, 
                                  :landing_time, :sortie_code, :touch_go, :pilot_comment, :full_stop, :mission_cancelled], 
                                capt_after_flight_attributes: [:flight_time, :user_id],
                                flightline_release_attributes: [:flight_time, :user_id],
                                techlogs_attributes: [:id, :work_unit_code_id, :user_id, :description, :type_cd, :_destroy],
                                post_mission_report_attributes: [:user_id, :aircraft_id, :oat, :idle_rpm, :max_rpm, :cht, :oil_temp, :oil_pressure, :map, :mag_drop_left, :mag_drop_right, :remarks, :mission_date],
                                after_flight_servicing_attributes: [:flight_time, :user_id, :oil_refill, :through_flight]
                                )
      end 
    end
end
