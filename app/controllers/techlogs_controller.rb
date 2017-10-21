class TechlogsController < ApplicationController
  before_action :set_techlog, only: [:show, :edit, :update, :destroy, 
    :create_addl_log, :create_limitation_log, :pdf, :create_techlog]

  # GET /techlogs
  # GET /techlogs.json
  def index
    if current_user.role == :admin
      @techlogs = Techlog.techloged
    else
      @techlogs = Techlog.techloged.where(:work_unit_code_id.in => current_user.work_unit_code_ids)
    #if current_user.role == :crew_cheif or current_user.role == :radio or current_user.role == :electrical or current_user.role == :instrument
      
    #else
      
    end
    
  end

  # GET /techlogs/1
  # GET /techlogs/1.json
  def show
  end

  # GET /techlogs/new
  def new
    @techlog = Techlog.new
    @techlog.log_date = Time.now.strftime("%d/%m/%Y")
    @techlog.build_work_performed if @techlog.work_performed.blank?
    @techlog.build_date_inspected if @techlog.date_inspected.blank?
    @techlog.build_work_duplicate if @techlog.work_duplicate.blank?
    if @techlog.dms_version.blank?
      @techlog.dms_version = System.first.settings['dms_version_number'] 
    end
  end

  # GET /techlogs/1/edit
  def edit
    @techlog.build_work_performed if @techlog.work_performed.blank?
    @techlog.build_date_inspected if @techlog.date_inspected.blank?
    @techlog.build_work_duplicate if @techlog.work_duplicate.blank?
    if @techlog.dms_version.blank?
      @techlog.dms_version = System.first.settings['dms_version_number'] 
    end
  end

  # POST /techlogs
  # POST /techlogs.json
  def create
    @techlog = Techlog.new(techlog_params)
    @techlog.log_date = Time.now.strftime("%Y-%m-%d")
    respond_to do |format|
      if @techlog.save
        format.html { redirect_to @techlog, notice: 'Techlog was successfully created.' }
        format.json { render :show, status: :created, location: @techlog }
      else
        puts @techlog.errors.inspect
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
    #   if params[:techlog][:change_parts_attributes].present?
    #     params[:techlog][:change_parts_attributes].each do |value,cp|
    #       if cp[:id].present? and cp[:_destroy].to_s == "1" and ChangePart.find(cp[:id]).present?          
    #         ChangePart.find(cp[:id]).destroy 
    #         params[:techlog][:change_parts_attributes].delete(value)
    #       end
    #     end
    #   end
      result = @techlog.update(techlog_params)
      puts result.inspect
      if result
        if @techlog.log_techloged?
          @techlog.is_completed = true
          @techlog.save
          format.html { redirect_to @techlog, notice: 'Techlog was successfully updated.' }
        elsif @techlog.log_addled?
          @techlog.addl_log_date = Time.now.strftime("%Y-%m-%d")
          @techlog.save
          format.html { redirect_to addl_log_path(@techlog), notice: 'Techlog was successfully updated.' }
        elsif @techlog.log_limited?
          @techlog.limitation_log_date = Time.now.strftime("%Y-%m-%d")
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
    render  pdf: "techlog_#{@techlog.id}",
      orientation: 'Landscape',
      template: 'techlogs/techlog_pdf.html.slim',
      layout: 'layouts/pdf/pdf.html.slim',
      show_as_html: false,
      locals: {
        :techlog => @techlog
      },
      page_height: '25in',
      page_width: '18in',
      margin:  {
        top: 0,                     # default 10 (mm)
        bottom: 0,
        left: 0,
        right:0 
      }
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
                                        :type, :action, :additional_detail_form, 
                                        :component_on_hold, :sap_notif, :sap_wo, :amr_no, :occurrence_report,
                                        :tools_used, :dms_version, :description,
                                        :addl_period_of_deferm, :addl_due, :addl_log_time, :addl_log_date,
                                        :limitation_period_of_deferm, :limitation_due, :limitation_log_time, :limitation_log_date, :limitation_description,
                                        flying_log_attributes: [ :fuel_refill, :oil_serviced, :oil_total_qty ],
                                        change_parts_attributes: [:id, :old_part_id, :new_part_id, :_destroy],
                                        work_performed_attributes: [:work_date, :work_time, :user_id],
                                        date_inspected_attributes: [:work_date, :work_time, :user_id],
                                        work_duplicate_attributes: [:work_date, :work_time, :user_id],
                                      )
    end
end
