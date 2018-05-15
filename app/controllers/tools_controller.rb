class ToolsController < ApplicationController
  before_action :set_tool, only: [:show, :edit, :update, :destroy]

  # GET /tools
  # GET /tools.json
  def index
    @tools = Tool.all
  end

  # GET /tools/1
  # GET /tools/1.json
  def show
  end

  # GET /tools/new
  def new
    @tool = Tool.new
  end

  # GET /tools/1/edit
  def edit
  end

  # POST /tools
  # POST /tools.json
  def create
    @tool = Tool.new(tool_params)

    respond_to do |format|
      if @tool.save
        format.html { redirect_to @tool, notice: 'Tool was successfully created.' }
        format.json { render :show, status: :created, location: @tool }
      else
        format.html { render :new }
        format.json { render json: @tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tools/1
  # PATCH/PUT /tools/1.json
  def update
    respond_to do |format|
      if @tool.update(tool_params)
        format.html { redirect_to @tool, notice: 'Tool was successfully updated.' }
        format.json { render :show, status: :ok, location: @tool }
      else
        format.html { render :edit }
        format.json { render json: @tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tools/1
  # DELETE /tools/1.json
  def destroy
    @tool.destroy
    respond_to do |format|
      format.html { redirect_to tools_url, notice: 'Tool was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    Tool.import(params[:file_excel])
    redirect_to tools_path, notice: 'Tools imported.'
  end

  # GET /tools/autocomplete_codes
  # GET /tools/autocomplete_codes.json
  def autocomplete
    search_string = params[:term]
    record = Tool.collection.aggregate([
      {"$match"=>{"quantity_in_hand"=>{"$gt"=>0}, "number"=>/#{search_string}.*/i}},
      {"$group" => {
          "_id" => "$number",
          "name" => { "$first": '$name' },          

      }},
      {"$limit" => 5}
    ])
    puts record.inspect
    # record = Tool.gt(quantity_in_hand: 0).where(number: /.*#{search_string}.*/i).limit(5)    
    render :json => record.map { |tool| 
      {
        id: Tool.where(number: tool[:_id]).first.id.to_s, 
        label: "#{tool[:_id]} (#{tool[:name]})", 
        value: "#{tool[:_id]} (#{tool[:name]})" 
        } 
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tool
      @tool = Tool.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tool_params
      params.fetch(:tool, {})
    end
end
