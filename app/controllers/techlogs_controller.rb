require 'combine_pdf'
class TechlogsController < ApplicationController
  before_action :set_techlog, only: [:show, :edit, :update, :destroy, 
    :create_addl_log, :create_limitation_log, :pdf, :create_techlog]

  # GET /techlogs
  # GET /techlogs.json
  def index
    if current_user.admin? or current_user.master_control? or current_user.chief_maintenance_officer?
      @techlogs = Techlog.techloged
    elsif current_user.log_asst?
      @techlogs = Techlog.where(:tools_state.in => ["requested", "provided"])    
    elsif current_user.logistics?
      @techlogs = Techlog.incomplete.where(:parts_state.in => ["requested", "provided"])
    else
      @techlogs = Techlog.techloged.where(
        {"$and" => [
          {
            "$or"=>[{"work_unit_code_id"=>{"$in"=>current_user.work_unit_code_ids}}, {"user_id"=>current_user}]
          },
          {
            "$or"=>[{condition_cd: 0}, {condition_cd: 2},{condition_cd: 0.to_s}, {condition_cd: 2.to_s}]
          }
        ]
      })
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
    if !@techlog.open?
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
    if current_user.work_unit_code_ids.present? and @techlog.work_unit_code.present? and current_user.work_unit_code_ids.include? @techlog.work_unit_code.id      
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
        # Parts required 
        if @techlog.parts_started? and @techlog.change_parts.count > 0
          @techlog.parts_requested_parts
        end
        if current_user.role == :logistics
          if @techlog.change_parts.where(available: 0).count > 0
            @techlog.parts_not_available_parts
          else
            change_part_all =  @techlog.change_parts.where("this.quantity_required == this.quantity_provided").where(provided: false)
            change_part_all.each do |cp|            
              cp.provided = true
              cp.update
            end
            change_parts_count = @techlog.change_parts.where("this.quantity_required != this.quantity_provided").count
            # if @techlog.change_parts.where(available: 0).count
            if change_parts_count > 0
              @techlog.parts_pending_parts
            else            
              @techlog.parts_provided_parts
            end
          end
        end
        
        # Tools 
        if @techlog.tools_started? and @techlog.requested_tools.count > 0
          @techlog.tools_requested_tools
        end
        if @techlog.tools_requested? and current_user.log_asst?
          @techlog.tools_provided_tools
        end
        if @techlog.tools_provided? and current_user.log_asst? and @techlog.assigned_tools.where(is_returned: false).count == 0
          @techlog.tools_returned_tools
        end
        # this one is for crew cheif
        if @techlog.flying_log.present? #and current_user.role == :crew_cheif
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
    # Use callbacks to share common setup or constraints between actions.
    def set_techlog
      @techlog = Techlog.find(params[:id])
      @techlog.current_user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def techlog_params
      params.require(:techlog).permit(:user_id,:work_unit_code_id, :aircraft_id, :location_id, :log_date, :log_time,
                                        :type, :condition, :action, :additional_detail_form, 
                                        :nmcs_pmcs, :demand_notif, :amf_reference_no, :pdr_number, :occurrence_report,
                                        :description,
                                        :addl_period_of_deferm, :addl_due, :addl_log_time, :addl_log_date,
                                        :limitation_period_of_deferm, :limitation_due, :limitation_log_time, :limitation_log_date, :limitation_description, :verified_tools,
                                        flying_log_attributes: [ :fuel_refill, :oil_serviced, :oil_total_qty ],
                                        change_parts_attributes: [:id, :requested_by_id, :assigned_by_id, :part_number, :quantity_required, :new_part_id, :quantity_provided, :available, :_destroy],
                                        requested_tools_attributes: [:id, :requested_by_id, :tool_no, :quantity_required, :_destroy],
                                        work_performed_attributes: [:work_date, :work_time, :user_id],
                                        date_inspected_attributes: [:work_date, :work_time, :user_id],
                                        work_duplicate_attributes: [:work_date, :work_time, :user_id],
                                      )
    end
end
