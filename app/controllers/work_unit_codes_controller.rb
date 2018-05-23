class WorkUnitCodesController < ApplicationController
  before_action :set_work_unit_code, only: [:show, :edit, :update, :destroy]

  # GET /work_unit_codes
  # GET /work_unit_codes.json
  def index
    @work_unit_codes = WorkUnitCode.all
  end

  # GET /work_unit_codes/1
  # GET /work_unit_codes/1.json
  def show
  end

  # GET /work_unit_codes/new
  def new
    @work_unit_code = WorkUnitCode.new
  end

  # GET /work_unit_codes/1/edit
  def edit
  end

  # POST /work_unit_codes
  # POST /work_unit_codes.json
  def create
    @work_unit_code = WorkUnitCode.new(work_unit_code_params)

    respond_to do |format|
      if @work_unit_code.save
        format.html { redirect_to @work_unit_code, notice: 'Work unit code was successfully created.' }
        format.json { render :show, status: :created, location: @work_unit_code }
      else
        format.html { 
          flash[:error] = @work_unit_code.errors.full_messages
          render :new 
        }
        format.json { render json: @work_unit_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /work_unit_codes/1
  # PATCH/PUT /work_unit_codes/1.json
  def update
    respond_to do |format|
      if @work_unit_code.update(work_unit_code_params)
        format.html { redirect_to @work_unit_code, notice: 'Work unit code was successfully updated.' }
        format.json { render :show, status: :ok, location: @work_unit_code }
      else
        format.html { render :edit }
        format.json { render json: @work_unit_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_unit_codes/1
  # DELETE /work_unit_codes/1.json
  def destroy
    @work_unit_code.destroy
    respond_to do |format|
      format.html { redirect_to work_unit_codes_url, notice: 'Work unit code was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /work_unit_codes/get_work_unit_codes
  # GET /work_unit_codes/get_work_unit_codes.json
  def get_work_unit_codes
    search_string = params[:q]
    wucs = WorkUnitCode.where(code: /.*#{search_string}.*/i).limit(30)
    respond_to do |format|
      format.json { render json: { items: wucs.map { |w| { id: w.id.to_s, code: w.code } }, total_count: wucs.length, incomplete_results: false } }
    end
  end

  # GET /work_unit_codes/autocomplete_codes
  # GET /work_unit_codes/autocomplete_codes.json
  def autocomplete_codes
    search_string = params[:term]
    record = WorkUnitCode.where(wuc_type_cd: 3).where(code: /.*#{search_string}.*/i).leaves.limit(5)
    
    render :json => record.map { |work_unit_code| {id: work_unit_code._id.to_s, label: work_unit_code.code, value: work_unit_code.code } }
  end

  def upload
    @part = WorkUnitCode.new
  end

  def import
    WorkUnitCode.import(params[:file_excel])
    redirect_to work_unit_codes_path, notice: 'Work unit codes imported.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_unit_code
      @work_unit_code = WorkUnitCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_unit_code_params
      params.require(:work_unit_code).permit(:code, :description, children_attributes: [:id, :code, :description, :wuc_type_cd, :_destroy])
    end
end
