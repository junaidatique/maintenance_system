class LimitationLogsController < ApplicationController
  before_action :set_limitation_log, only: [:show, :edit, :update, :destroy]

  # GET /limitation_logs
  # GET /limitation_logs.json
  def index
    @limitation_logs = LimitationLog.all
  end

  # GET /limitation_logs/1
  # GET /limitation_logs/1.json
  def show
  end

  # GET /limitation_logs/new
  def new
    @limitation_log = LimitationLog.new
  end

  # GET /limitation_logs/1/edit
  def edit
  end

  # POST /limitation_logs
  # POST /limitation_logs.json
  def create
    @limitation_log = LimitationLog.new(limitation_log_params)

    respond_to do |format|
      if @limitation_log.save
        format.html { redirect_to @limitation_log, notice: 'Limitation log was successfully created.' }
        format.json { render :show, status: :created, location: @limitation_log }
      else
        format.html { render :new }
        format.json { render json: @limitation_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /limitation_logs/1
  # PATCH/PUT /limitation_logs/1.json
  def update
    respond_to do |format|
      if @limitation_log.update(limitation_log_params)
        format.html { redirect_to @limitation_log, notice: 'Limitation log was successfully updated.' }
        format.json { render :show, status: :ok, location: @limitation_log }
      else
        format.html { render :edit }
        format.json { render json: @limitation_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /limitation_logs/1
  # DELETE /limitation_logs/1.json
  def destroy
    @limitation_log.destroy
    respond_to do |format|
      format.html { redirect_to limitation_logs_url, notice: 'Limitation log was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_limitation_log
      @limitation_log = LimitationLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def limitation_log_params
      params.fetch(:limitation_log, {})
    end
end
