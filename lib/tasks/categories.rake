namespace :categories do
  desc "重新计算所有分类的 tools_count 缓存（先更新叶子节点，再汇总父节点）"
  task recalculate_tools_count: :environment do
    puts "开始重新计算 tools_count ..."

    # 先更新所有叶子分类（无子分类）的直属工具数
    leaf_categories = Category.child_categories.to_a + Category.root_categories.select { |c| !c.has_children? }
    leaf_categories.uniq.each do |category|
      count = category.tools.count
      category.update_columns(tools_count: count)
      print "."
    end

    # 再更新有子分类的一级分类，汇总子分类的数量
    Category.root_categories.select(&:has_children?).each do |parent|
      count = parent.children.sum { |child| child.tools.count }
      parent.update_columns(tools_count: count)
      print "+"
    end

    puts "\n完成！"
    puts "分类统计："
    Category.order(:parent_id, :name).each do |c|
      level = c.root? ? "一级" : "二级"
      puts "  [#{level}] #{c.name}: #{c.tools_count} 个工具"
    end
  end
end
