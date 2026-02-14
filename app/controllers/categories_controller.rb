class CategoriesController < ApplicationController

  def index
    @categories = Category.popular
  end

  def show
    @category = Category.friendly.find(params[:id])
    @tools = @category.tools.newest.page(params[:page]).per(12)
  end

  def tools
    @category = Category.find(params[:id])
    @tools = @category.tools.newest
    render partial: 'tools_grid', locals: { category: @category, tools: @tools }, formats: [:html]
  end

  private
  # Write your private methods here
end
