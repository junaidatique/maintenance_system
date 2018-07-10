class WorkPackagesController < ApplicationController
  before_action :set_inspection
  before_action :set_work_package, only: [:show, :edit, :update, :destroy]

  # GET /work_packages
  # GET /work_packages.json
  def index
    @work_packages = WorkPackage.all
  end

  # GET /work_packages/1
  # GET /work_packages/1.json
  def show
  end

  # GET /work_packages/new
  def new
    @work_package = WorkPackage.new
  end

  # GET /work_packages/1/edit
  def edit
  end

  # POST /work_packages
  # POST /work_packages.json
  def create
    @work_package = WorkPackage.new(work_package_params)
    @work_package.inspection = @inspection
    respond_to do |format|
      if @work_package.save
        format.html { redirect_to @inspection, notice: 'Work package was successfully created.' }
        format.json { render :show, status: :created, location: @work_package }
      else
        format.html { render :new }
        format.json { render json: @work_package.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /work_packages/1
  # PATCH/PUT /work_packages/1.json
  def update
    respond_to do |format|
      if @work_package.update(work_package_params)
        format.html { redirect_to @inspection, notice: 'Work package was successfully updated.' }
        format.json { render :show, status: :ok, location: @work_package }
      else
        format.html { render :edit }
        format.json { render json: @work_package.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_packages/1
  # DELETE /work_packages/1.json
  def destroy
    @work_package.destroy
    respond_to do |format|
      format.html { redirect_to @inspection, notice: 'Work package was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def upload
    
  end

  def import
    WorkPackage.import(@inspection, params[:file_excel])
    redirect_to @inspection, notice: 'Work Package imported.'
  end

  private
    def set_inspection
      @inspection = Inspection.find(params[:inspection_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_work_package
      @work_package = WorkPackage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_package_params
      params.require(:work_package).permit(:description, :work_unit_code_id)      
    end
end
