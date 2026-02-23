require 'yaml'

data = {
  'categories' => [],
  'tools' => []
}

Category.order(:position, :id).each do |category|
  data['categories'] << {
    'name' => category.name,
    'description' => category.description,
    'parent' => category.parent&.name,
    'position' => category.position
  }
end

Tool.order(:id).each do |tool|
  data['tools'] << {
    'name' => tool.name,
    'website_url' => tool.website_url,
    'short_description' => tool.short_description,
    'long_description' => tool.long_description,
    'logo_url' => tool.logo_url,
    'featured' => tool.featured,
    'categories' => tool.categories.pluck(:name)
  }
end

File.write('db/data/kulawyer_tools.yml', data.to_yaml)
puts "✅ 已导出 #{data['categories'].length} 个分类和 #{data['tools'].length} 个工具到 db/data/kulawyer_tools.yml"
