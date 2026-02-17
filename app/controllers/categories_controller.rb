class CategoriesController < ApplicationController

  def index
    # Only show root categories (top-level), their children will be shown nested
    @categories = Category.root_categories.popular
  end

  def show
    @category = Category.friendly.find(params[:id])
    # Use all_tools to include subcategory tools for parent categories
    @tools = @category.all_tools.newest.page(params[:page]).per(12)
  end

  def tools
    @category = Category.find(params[:id])
    # Use all_tools to include subcategory tools for parent categories
    @tools = @category.all_tools.newest
    render partial: 'tools_grid', locals: { category: @category, tools: @tools }, formats: [:html]
  end

  private
  # Write your private methods here
end
