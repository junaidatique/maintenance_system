class TechlogsController < ApplicationController
  before_action :set_techlog, only: [:show, :edit, :update, :destroy, 
    :create_addl_log, :create_limitation_log, :pdf]

  # GET /techlogs
  # GET /techlogs.json
  def index
    if current_user.role == :admin
      @techlogs = Techlog.all
    else
      @techlogs = Techlog.where(:work_unit_code_id.in => current_user.work_unit_code_ids)
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
    respond_to do |format|
      assign_params = params.dup;

      puts params[:techlog][:change_parts_attributes].inspect
      params[:techlog][:change_parts_attributes].each do |value,cp|
        puts cp.inspect
        puts cp[:id].inspect
        puts cp[:_destroy].inspect
        if cp[:id].present? and cp[:_destroy].to_s == "1" and ChangePart.find(cp[:id]).present?
          puts 'here'
          ChangePart.find(cp[:id]).destroy 
          params[:techlog][:change_parts_attributes].delete(value)
        end
      end

      puts params[:techlog][:change_parts_attributes].inspect
      if @techlog.update(techlog_params)
        @techlog.is_completed = true
        @techlog.save
        format.html { redirect_to @techlog, notice: 'Techlog was successfully updated.' }
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
    addl = AddlLog.new
    addl.techlog = @techlog
    addl.save
    redirect_to addl_log_path(addl)
  end

  def create_limitation_log
    limit = LimitationLog.new
    limit.techlog = @techlog
    limit.save
    redirect_to limitation_log_path(limit)
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
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def techlog_params
      params.require(:techlog).permit(:user_id,:work_unit_code_id, :aircraft_id, :location_id, :log_date, :log_time,
                                        :type, :action, :additional_detail_form, 
                                        :component_on_hold, :sap_notif, :sap_wo, :amr_no, :occurrence_report,
                                        :tools_used, :dms_version, :description, 
                                        change_parts_attributes: [:id, :old_part_id, :new_part_id, :_destroy],
                                        work_performed_attributes: [:work_date, :work_time, :user_id],
                                        date_inspected_attributes: [:work_date, :work_time, :user_id],
                                        work_duplicate_attributes: [:work_date, :work_time, :user_id],
                                      )
    end
end
