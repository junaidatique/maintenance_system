class ScheduledInspectionsController < ApplicationController
  before_action :set_scheduled_inspection, only: [:show, :edit, :update, :destroy, :apply_extention, :save_extention, :cancel_extention, :create_techlog]

  # GET /scheduled_inspections
  # GET /scheduled_inspections.json
  def index
    if params[:type] == 'condition'
      @scheduled_inspections = ScheduledInspection.where(condition_cd: params[:condition].to_i).all
    else
      @scheduled_inspections = ScheduledInspection.where(status_cd: params[:status].to_i).all
    end
  end

  # GET /scheduled_inspections/1
  # GET /scheduled_inspections/1.json
  def show
  end
  
  def apply_extention
  end
  
  def save_extention    
    respond_to do |format|      
      @scheduled_inspection.condition_cd = 1
      if @scheduled_inspection.update(scheduled_inspection_params)
        format.html { redirect_to @scheduled_inspection, notice: 'Scheduled inspection was successfully updated.' }
        format.json { render :show, status: :ok, location: @scheduled_inspection }
      else
        format.html { render :apply_extention }
        format.json { render json: @scheduled_inspection.errors, status: :unprocessable_entity }
      end
    end    
  end

  def cancel_extention
    if @scheduled_inspection.condition_cd == 1
      @scheduled_inspection.condition_cd = 0
      redirect_to @scheduled_inspection, notice: 'Scheduled inspection extention was successfully canceled.'
    end
  end

  def create_techlog
    if @scheduled_inspection.status_cd == 2 and @scheduled_inspection.techlog.blank?
      @scheduled_inspection.update_scheduled_inspections @scheduled_inspection.completed_hours
      @scheduled_inspection.status_cd = 2
      @scheduled_inspection.save
      redirect_to @scheduled_inspection
    end
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
    # @scheduled_inspection = ScheduledInspection.new(scheduled_inspection_params)

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
      @scheduled_inspection.status_cd = 2
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
      # params.fetch(:scheduled_inspection, {})
      params.require(:scheduled_inspection).permit(:started_by_id, :inspection_started, :extention_hours, :extention_days)
    end
end
