require 'combine_pdf'
class TechlogsController < ApplicationController
  before_action :set_techlog, only: [:show, :edit, :update, :destroy, 
    :create_addl_log, :create_limitation_log, :pdf, :create_techlog, :approve_extension]
  before_action :set_parts, only: [:edit, :update]
  # GET /techlogs
  # GET /techlogs.json
  def index
    if can? :view_all_techlogs, Techlog
      @techlogs = Techlog.techloged
    elsif can? :view_open_techlogs, Techlog
      @techlogs = Techlog.techloged.incomplete.ne(type_cd: 3)
    elsif can? :logistics_techlog, Techlog
      @techlogs = Techlog.incomplete.where(:parts_state.in => ["requested", "provided"])
    else 
      # techlog_ids = current_user.autherization_codes.map{|auth| auth.techlogs.techloged.incomplete.map(&:id)}.reject{|techlog| techlog if techlog.blank?}.first 
      techlog_ids = Techlog.techloged.incomplete.in(autherization_code: current_user.autherization_codes.map(&:id)).map(&:id)
      if techlog_ids.present?
        techlog_ids = techlog_ids + current_user.techlogs.incomplete.map(&:id)
      else
        techlog_ids = current_user.techlogs.incomplete.map(&:id)
      end      
      @techlogs = Techlog.in(id: techlog_ids)
    end
    # if current_user.admin? or current_user.chief_maintenance_officer?
      
    # # elsif current_user.gen_fitt?
    # #   @techlogs = Techlog.where(:tools_state.in => ["requested", "provided"])    
    # elsif current_user.logistics?
      
    # else      
      
    # end

    respond_to do |format|
      format.html
      format.js { render json: TechlogDatatable.new(view_context, current_user, @techlogs)}
    end
    
  end

  # GET /techlogs/1
  # GET /techlogs/1.json
  def show
  end

  # GET /techlogs/new
  def new
    @techlog = Techlog.new
    @techlog.log_date = Time.zone.now.strftime("%d/%m/%Y")
    @techlog.location_from = "Al Zaeem M.B.A.A Academy"
    @techlog.build_work_performed if @techlog.work_performed.blank?
    @techlog.build_date_inspected if @techlog.date_inspected.blank?
    @techlog.build_work_duplicate if @techlog.work_duplicate.blank?
    if @techlog.dms_version.blank?
      @techlog.dms_version = System.first.settings['dms_version_number'] 
    end
  end

  # GET /techlogs/1/edit
  def edit
    if !@techlog.open? and cannot? :update_completed, Techlog
      redirect_to techlog_path(@techlog), :flash => { :error => "You can't edit completed techlog." }
    end
    if @techlog.interm_logs.incomplete.count > 0
      redirect_to techlog_path(@techlog), :flash => { :error => "Please complete all the interm logs." }
    end
    

    @techlog.build_work_performed if @techlog.work_performed.blank?
    @techlog.build_date_inspected if @techlog.date_inspected.blank?
    @techlog.build_work_duplicate if @techlog.work_duplicate.blank?
    if @techlog.dms_version.blank?
      @techlog.dms_version = System.first.settings['dms_version_number'] 
    end 
    if @techlog.autherization_code.present? and current_user.autherization_code_ids.include? @techlog.autherization_code.id
      @techlog.is_viewed = true
      @techlog.save :validate => false
    end    
  end

  # POST /techlogs
  # POST /techlogs.json
  def create
    @techlog = Techlog.new(techlog_params)
    @techlog.log_date = Time.zone.now.strftime("%Y-%m-%d")
    respond_to do |format|
      if @techlog.save
        if @techlog.tools_started? and @techlog.requested_tools.count > 0
          @techlog.tools_requested_tools
        end
        format.html { redirect_to @techlog, notice: 'Techlog was successfully created.' }
        format.json { render :show, status: :created, location: @techlog }
      else        
        format.html { render :new }
        format.json { render json: @techlog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /techlogs/1
  # PATCH/PUT /techlogs/1.json
  def update
    # puts @techlog.inspect
    # puts params.inspect
    # puts techlog_params.inspect

    respond_to do |format|
      if @techlog.update(techlog_params)
        @techlog.create_serial_no
        # Parts required 
        if @techlog.parts_started? and @techlog.change_parts.count > 0
          @techlog.parts_requested_parts
        end
        if current_user.role == :logistics
          if @techlog.change_parts.where(provided: false).count == 0
            @techlog.parts_provided_parts
          end          
        end
        
        # Tools 
        if @techlog.tools_started? and @techlog.requested_tools.count > 0
          @techlog.tools_requested_tools
        end
        if @techlog.tools_requested? and current_user.gen_fitt?
          @techlog.tools_provided_tools
        end
        if @techlog.tools_provided? and current_user.gen_fitt? and @techlog.assigned_tools.where(is_returned: false).count == 0
          @techlog.tools_returned_tools
        end
        # this one is for crew cheif
        if @techlog.flying_log.present?
          @techlog.flying_log.update_fuel
          @techlog.flying_log.fill_fuel
        end

        if @techlog.log_techloged?
          @techlog.is_completed = true
          @techlog.save
          format.html { redirect_to @techlog, notice: 'Techlog was successfully updated.' }
        elsif @techlog.log_addled?
          @techlog.addl_log_date = Time.zone.now.strftime("%Y-%m-%d")
          @techlog.save
          format.html { redirect_to addl_log_path(@techlog), notice: 'Techlog was successfully updated.' }
        elsif @techlog.log_limited?
          @techlog.limitation_log_date = Time.zone.now.strftime("%Y-%m-%d")
          @techlog.save
          format.html { redirect_to limitation_log_path(@techlog), notice: 'Techlog was successfully updated.' }
        end
        
        format.json { render :show, status: :ok, location: @techlog }
      else        
        format.html { render :edit }
        format.json { render json: @techlog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /techlogs/1
  # DELETE /techlogs/1.json
  def destroy
    @techlog.destroy
    respond_to do |format|
      format.html { redirect_to techlogs_url, notice: 'Techlog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def create_addl_log
    @techlog.change_to_addl_log
    redirect_to addl_log_path(@techlog)
  end
  def create_techlog
    @techlog.back_to_techlog_log
    redirect_to techlog_path(@techlog)
  end

  def create_limitation_log
    @techlog.add_to_limitation_log
    redirect_to limitation_log_path(@techlog)
  end
  def approve_extension    
    scheduled_inspection = @techlog.scheduled_inspection
    if scheduled_inspection.extention_hours.present? and scheduled_inspection.extention_hours > 0
      scheduled_inspection.hours = (scheduled_inspection.hours + scheduled_inspection.extention_hours).round(2)      
    end
    if scheduled_inspection.extention_days.present? and scheduled_inspection.extention_days > 0
      scheduled_inspection.calender_life_date = scheduled_inspection.calender_life_date + scheduled_inspection.extention_days      
    end
    scheduled_inspection.condition_cd = 2
    scheduled_inspection.save
    scheduled_inspection.calculate_status
    @techlog.is_extention_granted = 1
    @techlog.action = "Extension Granted"
    @techlog.condition_cd = 1
    @techlog.verified_tools = true
    @techlog.user = current_user
    @techlog.save!

    redirect_to limitation_log_path(@techlog)
  end

  def pdf
    # change_parts_val  = @techlog.change_parts.limit(4).offset(0)      
    # pdf_data = render(
    #       pdf: "techlog_#{@techlog.id}",
    #           orientation: 'Landscape',
    #           template: 'techlogs/techlog_pdf.html.slim',
    #           layout: 'layouts/pdf/pdf.html.slim',
    #           show_as_html: false,
    #           locals: {
    #             techlog: @techlog,
    #             change_parts_val: change_parts_val
    #           },
    #           page_height: '25in',
    #           page_width: '18in',
    #           margin:  {
    #             top: 0,                     # default 10 (mm)
    #             bottom: 0,
    #             left: 0,
    #             right:0 
    #           }
    #         )
            
    i = 0
    num = @techlog.change_parts.count
    merged_certificates = CombinePDF.new
    
    begin
      
      change_parts_val  = @techlog.change_parts.limit(4).offset(i)      
      pdf_data = render_to_string(
        pdf: "techlog_#{@techlog.id}",
        orientation: 'Landscape',
        template: 'techlogs/techlog_pdf.html.slim',
        layout: 'layouts/pdf/pdf.html.slim',
        show_as_html: false,
        locals: {
          techlog: @techlog,
          change_parts_val: change_parts_val
        },
        page_height: '25in',
        page_width: '18in',
        margin:  {
          top: 0,                     # default 10 (mm)
          bottom: 0,
          left: 0,
          right:0 
        }
      )
              
      merged_certificates  << CombinePDF.parse(pdf_data)
      i +=4  
    end while i < num
    send_data merged_certificates.to_pdf, :disposition => 'inline', :type => "application/pdf"

    
  end
  
  private
    def set_parts
      if @techlog.aircraft.present?
        @aircraft_parts = Part.collection.aggregate([
          {"$match"=>{"aircraft_id"=> @techlog.aircraft.id}},
          {"$group" => {
              "_id" => "$number",
              "name" => { "$first": '$description' },           
          }}      
        ])
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_techlog
      @techlog = Techlog.find(params[:id])
      @techlog.current_user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def techlog_params
      params.require(:techlog).permit(:user_id,:work_unit_code_id, :autherization_code_id, :updated_by, :aircraft_id, :location_id, :log_date, :log_time,
                                        :type, :condition, :action, :additional_detail_form, 
                                        :nmcs_pmcs, :demand_notif, :amf_reference_no, :pdr_number, :occurrence_report,
                                        :description, :closed_by_id,
                                        :addl_period_of_deferm, :addl_due, :addl_log_time, :addl_log_date,
                                        :limitation_period_of_deferm, :limitation_due, :limitation_log_time, :limitation_log_date, :limitation_description, :verified_tools,
                                        flying_log_attributes: [ :fuel_refill, :oil_serviced, :oil_total_qty ],
                                        change_parts_attributes: [:id, :requested_by_id, :assigned_by_id, :part_id, :quantity_required, :new_part_id, :old_part_id, :quantity_provided, :provided, :is_servicable, :_destroy],
                                        requested_tools_attributes: [:id, :requested_by_id, :tool_no, :quantity_required, :_destroy],
                                        work_performed_attributes: [:work_date, :work_time, :user_id],
                                        date_inspected_attributes: [:work_date, :work_time, :user_id],
                                        work_duplicate_attributes: [:work_date, :work_time, :user_id],
                                      )
    end
end
