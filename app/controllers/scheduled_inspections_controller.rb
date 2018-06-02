class ScheduledInspectionsController < ApplicationController
  before_action :set_scheduled_inspection, only: [:show, :edit, :update, :destroy]

  # GET /scheduled_inspections
  # GET /scheduled_inspections.json
  def index
    @scheduled_inspections = ScheduledInspection.all
  end

  # GET /scheduled_inspections/1
  # GET /scheduled_inspections/1.json
  def show
  end

  # GET /scheduled_inspections/new
  def new
    @scheduled_inspection = ScheduledInspection.new
  end

  # GET /scheduled_inspections/1/edit
  def edit
  end

  # POST /scheduled_inspections
  # POST /scheduled_inspections.json
  def create
    @scheduled_inspection = ScheduledInspection.new(scheduled_inspection_params)

    respond_to do |format|
      if @scheduled_inspection.save
        format.html { redirect_to @scheduled_inspection, notice: 'Scheduled inspection was successfully created.' }
        format.json { render :show, status: :created, location: @scheduled_inspection }
      else
        format.html { render :new }
        format.json { render json: @scheduled_inspection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scheduled_inspections/1
  # PATCH/PUT /scheduled_inspections/1.json
  def update
    respond_to do |format|
      if @scheduled_inspection.update(scheduled_inspection_params)
        format.html { redirect_to @scheduled_inspection, notice: 'Scheduled inspection was successfully updated.' }
        format.json { render :show, status: :ok, location: @scheduled_inspection }
      else
        format.html { render :edit }
        format.json { render json: @scheduled_inspection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scheduled_inspections/1
  # DELETE /scheduled_inspections/1.json
  def destroy
    @scheduled_inspection.destroy
    respond_to do |format|
      format.html { redirect_to scheduled_inspections_url, notice: 'Scheduled inspection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scheduled_inspection
      @scheduled_inspection = ScheduledInspection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scheduled_inspection_params
      params.fetch(:scheduled_inspection, {})
    end
end
