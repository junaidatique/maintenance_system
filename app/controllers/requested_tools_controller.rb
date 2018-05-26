class RequestedToolsController < ApplicationController
  before_action :set_requested_tool, only: [:show, :edit, :update, :destroy]

  # GET /requested_tools
  # GET /requested_tools.json
  def index
    @requested_tools = RequestedTool.requested.all
  end

  # GET /requested_tools/1
  # GET /requested_tools/1.json
  def show
  end

  # GET /requested_tools/new
  def new
    @requested_tool = RequestedTool.new
  end

  # GET /requested_tools/1/edit
  def edit
  end

  # POST /requested_tools
  # POST /requested_tools.json
  def create
    @requested_tool = RequestedTool.new(requested_tool_params)
    respond_to do |format|
      if @requested_tool.save
        format.html { redirect_to @requested_tool, notice: 'Requested tool was successfully created.' }
        format.json { render :show, status: :created, location: @requested_tool }
      else
        format.html { render :new }
        format.json { render json: @requested_tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /requested_tools/1
  # PATCH/PUT /requested_tools/1.json
  def update
    respond_to do |format|
      if @requested_tool.update!(requested_tool_params)
        @requested_tool.assigned_tools.map{|assigned_tool| assigned_tool.update_quantity}        
        # if !@requested_tool.is_assigned? and @requested_tool.assigned_tools.where(serial_no: nil).count == 0
        #   @requested_tool.is_assigned = true
        #   @requested_tool.save
        # end
        # if @requested_tool.is_assigned? and @requested_tool.assigned_tools.where(is_returned: false).count == 0
        #   @requested_tool.is_returned = true
        #   @requested_tool.save
        # end
        format.html { redirect_to @requested_tool, notice: 'Requested tool was successfully updated.' }
        format.json { render :show, status: :ok, location: @requested_tool }
      else
        format.html { render :edit }
        format.json { render json: @requested_tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /requested_tools/1
  # DELETE /requested_tools/1.json
  def destroy
    @requested_tool.destroy
    respond_to do |format|
      format.html { redirect_to requested_tools_url, notice: 'Requested tool was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_requested_tool
      @requested_tool = RequestedTool.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def requested_tool_params
      params.require(:requested_tool).permit(
        assigned_tools_attributes: [:id, :assigned_by_id, :serial_no, :is_returned, :is_assigned, :_destroy],
      )
      
    end
end
