class TechnicalOrdersController < ApplicationController
  before_action :set_technical_order, only: [:show, :edit, :update, :destroy]

  # GET /technical_orders
  # GET /technical_orders.json
  def index
    @technical_orders = TechnicalOrder.all
  end

  # GET /technical_orders/1
  # GET /technical_orders/1.json
  def show
  end

  # GET /technical_orders/new
  def new
    @technical_order = TechnicalOrder.new
  end

  # GET /technical_orders/1/edit
  def edit
  end

  # POST /technical_orders
  # POST /technical_orders.json
  def create
    @technical_order = TechnicalOrder.new(technical_order_params)

    respond_to do |format|
      if @technical_order.save
        format.html { redirect_to @technical_order, notice: 'Technical order was successfully created.' }
        format.json { render :show, status: :created, location: @technical_order }
      else
        format.html { render :new }
        format.json { render json: @technical_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /technical_orders/1
  # PATCH/PUT /technical_orders/1.json
  def update
    respond_to do |format|
      if @technical_order.update(technical_order_params)
        format.html { redirect_to @technical_order, notice: 'Technical order was successfully updated.' }
        format.json { render :show, status: :ok, location: @technical_order }
      else
        format.html { render :edit }
        format.json { render json: @technical_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /technical_orders/1
  # DELETE /technical_orders/1.json
  def destroy
    @technical_order.destroy
    respond_to do |format|
      format.html { redirect_to technical_orders_url, notice: 'Technical order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_technical_order
      @technical_order = TechnicalOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def technical_order_params
      params.require(:technical_order).permit(:name)
    end
end
