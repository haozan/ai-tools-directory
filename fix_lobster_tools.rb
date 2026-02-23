category = Category.find_by(name: '龙虾频道')

# 删除 Coze 和扣子工具
Tool.where(name: ['Coze', '扣子']).destroy_all

# 确保 有道龙虾 关联到龙虾频道
youdao = Tool.find_by(name: '有道龙虾')
if youdao && !youdao.categories.include?(category)
  youdao.categories << category
end

# 查找或创建 openclaw 工具
openclaw = Tool.find_or_create_by!(name: 'openclaw') do |t|
  t.website_url = 'https://openclaw.cn/'
  t.short_description = 'OpenClaw AI 工具平台'
  t.logo_url = ''
  t.featured = false
end

# 关联 openclaw 到龙虾频道
openclaw.categories << category unless openclaw.categories.include?(category)

# 更新计数
category.update(tools_count: category.tools.count)

puts '✅ 已删除 Coze 和扣子'
puts '✅ 龙虾频道现在包含 2 个工具：'
category.tools.each { |t| puts "  - #{t.name} (#{t.website_url})" }
puts "总工具数: #{Tool.count}"
