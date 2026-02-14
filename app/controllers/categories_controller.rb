class CategoriesController < ApplicationController

  def index
    @categories = Category.popular
  end

  def show
    @category = Category.friendly.find(params[:id])
    @tools = @category.tools.newest.page(params[:page]).per(12)
  end

  private
  # Write your private methods here
end
