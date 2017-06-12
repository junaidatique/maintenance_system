class TechlogsController < ApplicationController
  before_action :set_techlog, only: [:show, :edit, :update, :destroy]

  # GET /techlogs
  # GET /techlogs.json
  def index
    @techlogs = Techlog.all
  end

  # GET /techlogs/1
  # GET /techlogs/1.json
  def show
  end

  # GET /techlogs/new
  def new
    @techlog = Techlog.new
  end

  # GET /techlogs/1/edit
  def edit
  end

  # POST /techlogs
  # POST /techlogs.json
  def create
    @techlog = Techlog.new(techlog_params)

    respond_to do |format|
      if @techlog.save
        format.html { redirect_to @techlog, notice: 'Techlog was successfully created.' }
        format.json { render :show, status: :created, location: @techlog }
      else
        format.html { render :new }
        format.json { render json: @techlog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /techlogs/1
  # PATCH/PUT /techlogs/1.json
  def update
    respond_to do |format|
      if @techlog.update(techlog_params)
        format.html { redirect_to @techlog, notice: 'Techlog was successfully updated.' }
        format.json { render :show, status: :ok, location: @techlog }
      else
        format.html { render :edit }
        format.json { render json: @techlog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /techlogs/1
  # DELETE /techlogs/1.json
  def destroy
    @techlog.destroy
    respond_to do |format|
      format.html { redirect_to techlogs_url, notice: 'Techlog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_techlog
      @techlog = Techlog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def techlog_params
      params.fetch(:techlog, {})
    end
end
