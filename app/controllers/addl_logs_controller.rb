class AddlLogsController < ApplicationController
  before_action :set_addl_log, only: [:show, :edit, :update, :destroy]

  # GET /addl_logs
  # GET /addl_logs.json
  def index
    @addl_logs = AddlLog.all
  end

  # GET /addl_logs/1
  # GET /addl_logs/1.json
  def show
  end

  # GET /addl_logs/new
  def new
    @addl_log = AddlLog.new
  end

  # GET /addl_logs/1/edit
  def edit
    @addl_log.build_addl_rectification if @addl_log.addl_rectification.blank?
  end

  # POST /addl_logs
  # POST /addl_logs.json
  def create
    @addl_log = AddlLog.new(addl_log_params)

    respond_to do |format|
      if @addl_log.save
        format.html { redirect_to @addl_log, notice: 'Addl log was successfully created.' }
        format.json { render :show, status: :created, location: @addl_log }
      else
        format.html { render :new }
        format.json { render json: @addl_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /addl_logs/1
  # PATCH/PUT /addl_logs/1.json
  def update
    respond_to do |format|
      if @addl_log.update(addl_log_params)
        format.html { redirect_to @addl_log, notice: 'Addl log was successfully updated.' }
        format.json { render :show, status: :ok, location: @addl_log }
      else
        format.html { render :edit }
        format.json { render json: @addl_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /addl_logs/1
  # DELETE /addl_logs/1.json
  def destroy
    @addl_log.destroy
    respond_to do |format|
      format.html { redirect_to addl_logs_url, notice: 'Addl log was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_addl_log
      @addl_log = AddlLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def addl_log_params
      params.require(:addl_log).permit(:description, :period_of_deferm, :due, :log_date, 
                    :log_time, :user_id,
                    addl_rectification_attributes: [:description, :log_date, :log_time, :user_id]
                    )
    end
end
