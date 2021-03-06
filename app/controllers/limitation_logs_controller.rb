class LimitationLogsController < ApplicationController
  before_action :set_limitation_log, only: [:show, :edit, :update, :destroy, :pdf]

  # GET /limitation_logs
  # GET /limitation_logs.json
  def index
    @limitation_logs = Techlog.limited
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
    @techlog.limitation_log_date = Time.zone.now.strftime("%d/%m/%Y")
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
  def pdf    
    pdf_data = render(
          pdf: "techlog_#{@techlog.id}",
              orientation: 'Landscape',
              template: 'limitation_logs/limitation_log_pdf.html.slim',
              layout: 'layouts/pdf/pdf.html.slim',
              show_as_html: false,
              locals: {
                techlog: @techlog                
              },
              page_height: '25in',
              page_width: '18in',
              margin:  {
                top: 0,                     # default 10 (mm)
                bottom: 0,
                left: 0,
                right:0 
              }
            )
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_limitation_log
      @limitation_log = Techlog.find(params[:id])
      @techlog = Techlog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def limitation_log_params
      params.require(:limitation_log).permit(:description, :period_of_deferm, :due, :log_date, 
                    :log_time, :user_id,
                    limitation_rectification_attributes: [:description, :log_date, :log_time, :user_id]
                    )
    end
end
