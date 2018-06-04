class InspectionsController < ApplicationController
  before_action :set_type
  before_action :set_inspection, only: [:show, :edit, :update, :destroy]

  # GET /inspections
  # GET /inspections.json
  def index
    @inspections = Inspection.where(type_cd: @type_cd.to_i).all
  end

  # GET /inspections/1
  # GET /inspections/1.json
  def show
  end

  # GET /inspections/new
  def new
    @inspection = Inspection.new
  end

  # GET /inspections/1/edit
  def edit
  end

  # POST /inspections
  # POST /inspections.json
  def create
    @inspection = Inspection.new(inspection_params)

    respond_to do |format|
      if @inspection.save
        format.html { redirect_to @inspection, notice: 'Inspection was successfully created.' }
        format.json { render :show, status: :created, location: @inspection }
      else
        format.html { render :new }
        format.json { render json: @inspection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inspections/1
  # PATCH/PUT /inspections/1.json
  def update
    respond_to do |format|
      if @inspection.update(inspection_params)
        format.html { redirect_to @inspection, notice: 'Inspection was successfully updated.' }
        format.json { render :show, status: :ok, location: @inspection }
      else
        format.html { render :edit }
        format.json { render json: @inspection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inspections/1
  # DELETE /inspections/1.json
  def destroy
    @inspection.destroy
    respond_to do |format|
      format.html { redirect_to inspections_url(type_cd: @type_cd), notice: 'Inspection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_type
      if params[:type_cd].blank?
        # redirect_to aircrafts_path()
      end
      @type_cd = params[:type_cd]
    end
    def set_inspection
      @inspection = Inspection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inspection_params
      params.require(:inspection).permit(:name, :no_of_hours, :calender_value, :type_cd, :part_number, :duration)
    end
end
