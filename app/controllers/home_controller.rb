class HomeController < ApplicationController
  include HomeDemoConcern

  def index
    @tools = Tool.includes(:categories).newest.limit(8)
    @categories = Category.popular.limit(6)
    @tools_count = Tool.count
    @categories_count = Category.count
  end
end
