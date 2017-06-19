class TechlogsController < ApplicationController
  before_action :set_techlog, only: [:show, :edit, :update, :destroy, 
    :create_addl_log, :create_limitation_log]

  # GET /techlogs
  # GET /techlogs.json
  def index
    @techlogs = Techlog.all
  end

  # GET /techlogs/1
  # GET /techlogs/1.json
  def show
  end

  # GET /techlogs/new
  def new
    @techlog = Techlog.new
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

    respond_to do |format|
      if @techlog.save
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
    respond_to do |format|
      if @techlog.update(techlog_params)
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_techlog
      @techlog = Techlog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def techlog_params
      params.require(:techlog).permit(:work_unit_code_id, :type, :action, :additional_detail_form, 
                                        :component_on_hold, :sap_notif, :sap_wo, :amr_no, :occurrence_report,
                                        :tools_used, :dms_version, 
                                        change_parts_attributes: [:pin_out, :serial_number_out, :pin_in, :serial_number_in, :_destroy],
                                          work_performed_attributes: [:work_date, :work_time, :user_id],
                                          date_inspected_attributes: [:work_date, :work_time, :user_id],
                                          work_duplicate_attributes: [:work_date, :work_time, :user_id],
                                          )
    end
end
