class CategoriesController < ApplicationController

  def show
    @category = Category.friendly.find(params[:id])
    @tools = @category.tools.newest.page(params[:page]).per(12)
    @all_categories = Category.popular.limit(10)
  end

  private
  # Write your private methods here
end
