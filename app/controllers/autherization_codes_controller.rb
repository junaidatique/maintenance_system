class AutherizationCodesController < ApplicationController
  before_action :set_autherization_code, only: [:show, :edit, :update, :destroy]

  # GET /autherization_codes
  # GET /autherization_codes.json
  def index
    @autherization_codes = AutherizationCode.all
  end

  # GET /autherization_codes/1
  # GET /autherization_codes/1.json
  def show
  end

  # GET /autherization_codes/new
  def new
    @autherization_code = AutherizationCode.new
  end

  # GET /autherization_codes/1/edit
  def edit
  end

  # POST /autherization_codes
  # POST /autherization_codes.json
  def create
    @autherization_code = AutherizationCode.new(autherization_code_params)

    respond_to do |format|
      if @autherization_code.save
        format.html { redirect_to @autherization_code, notice: 'Autherization code was successfully created.' }
        format.json { render :show, status: :created, location: @autherization_code }
      else
        format.html { render :new }
        format.json { render json: @autherization_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /autherization_codes/1
  # PATCH/PUT /autherization_codes/1.json
  def update
    respond_to do |format|
      if @autherization_code.update(autherization_code_params)
        format.html { redirect_to @autherization_code, notice: 'Autherization code was successfully updated.' }
        format.json { render :show, status: :ok, location: @autherization_code }
      else
        format.html { render :edit }
        format.json { render json: @autherization_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /autherization_codes/1
  # DELETE /autherization_codes/1.json
  def destroy
    @autherization_code.destroy
    respond_to do |format|
      format.html { redirect_to autherization_codes_url, notice: 'Autherization code was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /autherization_codes/get_autherization_codes
  # GET /autherization_codes/get_autherization_codes.json
  def get_codes
    search_string = params[:q]
    auth_codes = AutherizationCode.where(code: /.*#{search_string}.*/i)
    respond_to do |format|
      format.json { render json: { items: auth_codes.map { |ac| { id: ac.id.to_s, code: ac.autherization_code_format } }, total_count: auth_codes.length, incomplete_results: false } }
    end
  end

  # GET /autherization_codes/autocomplete_codes
  # GET /autherization_codes/autocomplete_codes.json
  def autocomplete_codes
    search_string = params[:term]
    record = AutherizationCode.where(inspection_type: /.*#{search_string}.*/i)
    
    render :json => record.map { |autherization_code| {id: autherization_code._id.to_s, label: autherization_code.autherization_code_format, value: autherization_code.autherization_code_format } }
  end

  def upload
    @autherization_code = AutherizationCode.new
  end

  def import
    AutherizationCode.import(params[:file_excel])
    redirect_to autherization_codes_path, notice: 'Autherization Codes imported.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_autherization_code
      @autherization_code = AutherizationCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def autherization_code_params
      params.require(:autherization_code).permit(:code, :inspection_type, :autherized_trade)      
    end
end
