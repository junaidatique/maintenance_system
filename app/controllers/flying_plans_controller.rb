class FlyingPlansController < ApplicationController
  before_action :set_flying_plan, only: [:show, :edit, :update, :destroy]

  # GET /flying_plans
  # GET /flying_plans.json
  def index
    @flying_plans = FlyingPlan.all
  end

  # GET /flying_plans/1
  # GET /flying_plans/1.json
  def show
  end

  # GET /flying_plans/new
  def new
    @flying_plan = FlyingPlan.new
  end

  # GET /flying_plans/1/edit
  def edit
  end

  # POST /flying_plans
  # POST /flying_plans.json
  def create
    @flying_plan = FlyingPlan.new(flying_plan_params)

    respond_to do |format|
      if @flying_plan.save
        format.html { redirect_to @flying_plan, notice: 'Flying plan was successfully created.' }
        format.json { render :show, status: :created, location: @flying_plan }
      else
        format.html { render :new }
        format.json { render json: @flying_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /flying_plans/1
  # PATCH/PUT /flying_plans/1.json
  def update
    respond_to do |format|
      if @flying_plan.update(flying_plan_params)
        format.html { redirect_to @flying_plan, notice: 'Flying plan was successfully updated.' }
        format.json { render :show, status: :ok, location: @flying_plan }
      else
        format.html { render :edit }
        format.json { render json: @flying_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /flying_plans/1
  # DELETE /flying_plans/1.json
  def destroy
    @flying_plan.destroy
    respond_to do |format|
      format.html { redirect_to flying_plans_url, notice: 'Flying plan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flying_plan
      @flying_plan = FlyingPlan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def flying_plan_params
      params.require(:flying_plan).permit(:flying_date, :is_flying, :reason, aircraft_ids: [])
    end
end
