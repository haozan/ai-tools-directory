class HomeController < ApplicationController
  include HomeDemoConcern

  def index
    # 优先显示精选工具，不足8个时用最新工具补充
    featured_tools = Tool.includes(:categories).featured.limit(8)
    if featured_tools.size < 8
      additional_tools = Tool.includes(:categories).newest.where.not(id: featured_tools.pluck(:id)).limit(8 - featured_tools.size)
      @tools = featured_tools + additional_tools
    else
      @tools = featured_tools
    end
    @categories = Category.popular.limit(6)
    @tools_count = Tool.count
    @categories_count = Category.count
  end
end
