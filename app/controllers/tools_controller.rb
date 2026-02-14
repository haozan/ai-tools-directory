class ToolsController < ApplicationController

  def index
    @tools = Tool.includes(:categories)
    @tools = @tools.search_by_name(params[:q]) if params[:q].present?
    @tools = @tools.by_pricing(params[:pricing]) if params[:pricing].present?
    
    if params[:category_id].present?
      @category = Category.friendly.find(params[:category_id])
      @tools = @category.tools
    end
    
    @tools = case params[:sort]
             when 'popular' then @tools.popular
             when 'newest' then @tools.newest
             else @tools.newest
             end
    
    @tools = @tools.page(params[:page]).per(12)
    @categories = Category.popular.limit(6)
  end


  def show
    @tool = Tool.friendly.find(params[:id])
    @tool.increment!(:view_count)
    @related_tools = @tool.categories.first&.tools&.where&.not(id: @tool.id)&.limit(4) || []
  end

  private
  # Write your private methods here
end
