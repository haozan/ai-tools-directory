class SubmissionsController < ApplicationController

  def new
    @tool = Tool.new
    @categories = Category.order(:name)
  end


  def create
    @tool = Tool.new(tool_params)
    
    if @tool.save
      redirect_to tools_path, notice: 'Thank you for your submission! We will review it shortly.'
    else
      @categories = Category.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private
  
  def tool_params
    params.require(:tool).permit(:name, :website_url, :short_description, :long_description, :logo_url, :pricing_type, category_ids: [])
  end
end
