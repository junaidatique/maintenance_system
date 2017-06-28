class NonFlyingDaysController < ApplicationController
  before_action :set_non_flying_day, only: [:show, :edit, :update, :destroy]

  # GET /non_flying_days
  # GET /non_flying_days.json
  def index
    @non_flying_days = NonFlyingDay.all
  end

  # GET /non_flying_days/1
  # GET /non_flying_days/1.json
  def show
  end

  # GET /non_flying_days/new
  def new
    @non_flying_day = NonFlyingDay.new
  end

  # GET /non_flying_days/1/edit
  def edit
  end

  # POST /non_flying_days
  # POST /non_flying_days.json
  def create
    @non_flying_day = NonFlyingDay.new(non_flying_day_params)

    respond_to do |format|
      if @non_flying_day.save
        format.html { redirect_to non_flying_days_url, notice: 'Non flying day was successfully created.' }
        format.json { render :show, status: :created, location: @non_flying_day }
      else
        format.html { render :new }
        format.json { render json: @non_flying_day.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /non_flying_days/1
  # PATCH/PUT /non_flying_days/1.json
  def update
    respond_to do |format|
      if @non_flying_day.update(non_flying_day_params)
        format.html { redirect_to non_flying_days_url, notice: 'Non flying day was successfully updated.' }
        format.json { render :show, status: :ok, location: @non_flying_day }
      else
        format.html { render :edit }
        format.json { render json: @non_flying_day.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /non_flying_days/1
  # DELETE /non_flying_days/1.json
  def destroy
    @non_flying_day.destroy
    respond_to do |format|
      format.html { redirect_to non_flying_days_url, notice: 'Non flying day was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_non_flying_day
      @non_flying_day = NonFlyingDay.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def non_flying_day_params
      params.require(:non_flying_day).permit(:date, :reason)
    end
end
