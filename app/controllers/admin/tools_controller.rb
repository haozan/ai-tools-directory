class Admin::ToolsController < Admin::BaseController
  before_action :set_tool, only: [:show, :edit, :update, :destroy]

  def index
    @tools = Tool.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @tool = Tool.new
  end

  def create
    @tool = Tool.new(tool_params)

    if @tool.save
      redirect_to admin_tool_path(@tool), notice: 'Tool was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tool.update(tool_params)
      redirect_to admin_tool_path(@tool), notice: 'Tool was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tool.destroy
    redirect_to admin_tools_path, notice: 'Tool was successfully deleted.'
  end

  private

  def set_tool
    @tool = Tool.find(params[:id])
  end

  def tool_params
    params.require(:tool).permit(:name, :website_url, :short_description, :long_description, :logo_url, :logo, :featured, :slug, :view_count, category_ids: [])
  end
end
