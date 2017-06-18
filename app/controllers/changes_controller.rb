class ChangesController < ApplicationController
  before_action :set_technical_order
  before_action :set_change, only: [:show, :edit, :update, :destroy]

  # GET /changes
  # GET /changes.json
  def index
    @changes = @technical_order.changes.all
  end

  # GET /changes/1
  # GET /changes/1.json
  def show
  end

  # GET /changes/new
  def new
    @change = Change.new
  end

  # GET /changes/1/edit
  def edit
  end

  # POST /changes
  # POST /changes.json
  def create
    @change = Change.new(change_params)
    @change.technical_order = @technical_order
    
    respond_to do |format|
      if @change.save
        format.html { redirect_to @technical_order, notice: 'Change was successfully created.' }
        format.json { render :show, status: :created, location: @change }
      else
        format.html { render :new }
        format.json { render json: @change.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /changes/1
  # PATCH/PUT /changes/1.json
  def update
    respond_to do |format|
      if @change.update(change_params)
        format.html { redirect_to @change, notice: 'Change was successfully updated.' }
        format.json { render :show, status: :ok, location: @change }
      else
        format.html { render :edit }
        format.json { render json: @change.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /changes/1
  # DELETE /changes/1.json
  def destroy
    @change.destroy
    respond_to do |format|
      format.html { redirect_to @technical_order, notice: 'Change was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    
    def set_technical_order
      @technical_order = TechnicalOrder.find(params[:technical_order_id])
    end

    def set_change
      @change = @technical_order.technical_changes.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def change_params
      params.require(:change).permit(:change_number)
    end
end
