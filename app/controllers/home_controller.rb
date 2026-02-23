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
    
    # 预加载热门分类用于首页展示
    trending_names = ["龙虾频道", "AI 编程", "AI 阅卷", "AI 语音输出", "AI 起草文书", "AI 合同审核", "AI 写作"]
    @trending_categories = Category.where(name: trending_names).index_by(&:name)
  end
end
