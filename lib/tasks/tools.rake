namespace :tools do
  desc "从 YAML 文件导入工具数据"
  task import: :environment do
    require 'yaml'
    
    file_path = Rails.root.join('db', 'data', 'tools.yml')
    
    unless File.exist?(file_path)
      puts "❌ 文件不存在: #{file_path}"
      puts "请先创建 db/data/tools.yml 文件"
      exit 1
    end
    
    puts "📂 正在读取文件: #{file_path}"
    data = YAML.load_file(file_path)
    
    # 首先创建/更新分类（支持二级分类）
    if data['categories']
      puts "\n📁 正在处理分类..."
      
      # 第一轮：创建所有一级分类（没有 parent 字段的）
      root_categories = data['categories'].select { |cat| cat['parent'].blank? }
      root_categories.each do |cat_data|
        category = Category.find_or_initialize_by(name: cat_data['name'], parent_id: nil)
        category.description = cat_data['description']
        
        if category.save
          puts "  ✅ #{category.new_record? ? '创建' : '更新'}一级分类: #{category.name}"
        else
          puts "  ❌ 分类保存失败: #{category.name} - #{category.errors.full_messages.join(', ')}"
        end
      end
      
      # 第二轮：创建所有二级分类（有 parent 字段的）
      child_categories = data['categories'].select { |cat| cat['parent'].present? }
      child_categories.each do |cat_data|
        parent = Category.find_by(name: cat_data['parent'])
        
        unless parent
          puts "  ⚠️  跳过：父分类 '#{cat_data['parent']}' 不存在，请先创建父分类"
          next
        end
        
        category = Category.find_or_initialize_by(name: cat_data['name'], parent_id: parent.id)
        category.description = cat_data['description']
        
        if category.save
          puts "  ✅ #{category.new_record? ? '创建' : '更新'}二级分类: #{category.name} (父级: #{parent.name})"
        else
          puts "  ❌ 分类保存失败: #{category.name} - #{category.errors.full_messages.join(', ')}"
        end
      end
    end
    
    # 然后创建/更新工具
    if data['tools']
      puts "\n🔧 正在处理工具..."
      success_count = 0
      skip_count = 0
      error_count = 0
      
      data['tools'].each_with_index do |tool_data, index|
        begin
          # 查找或创建工具
          tool = Tool.find_or_initialize_by(name: tool_data['name'])
          
          # 如果工具已存在且没有变化，跳过
          if !tool.new_record? && 
             tool.website_url == tool_data['website_url'] && 
             tool.short_description == tool_data['short_description']
            puts "  ⏭️  跳过（已存在且无变化）: #{tool.name}"
            skip_count += 1
            next
          end
          
          # 更新属性
          tool.website_url = tool_data['website_url']
          tool.short_description = tool_data['short_description']
          tool.long_description = tool_data['long_description'] if tool_data['long_description'].present?
          tool.logo_url = tool_data['logo_url'] if tool_data['logo_url'].present?
          tool.pricing_type = tool_data['pricing_type']
          
          if tool.save
            # 关联分类
            if tool_data['categories'].present?
              category_names = tool_data['categories']
              categories = Category.where(name: category_names)
              
              if categories.count != category_names.count
                missing = category_names - categories.pluck(:name)
                puts "  ⚠️  警告: 以下分类不存在: #{missing.join(', ')}"
              end
              
              tool.categories = categories
            end
            
            puts "  ✅ #{tool.previously_new_record? ? '创建' : '更新'}工具: #{tool.name} (#{tool.pricing_type})"
            success_count += 1
          else
            puts "  ❌ 工具保存失败: #{tool.name}"
            puts "     错误: #{tool.errors.full_messages.join(', ')}"
            error_count += 1
          end
        rescue StandardError => e
          puts "  ❌ 处理失败: #{tool_data['name']} - #{e.message}"
          error_count += 1
        end
      end
      
      puts "\n" + "="*60
      puts "📊 导入统计:"
      puts "  ✅ 成功: #{success_count} 个"
      puts "  ⏭️  跳过: #{skip_count} 个"
      puts "  ❌ 失败: #{error_count} 个"
      puts "  📦 总计: #{data['tools'].count} 个"
      puts "="*60
      
      # 更新分类计数
      puts "\n🔄 正在更新分类工具计数..."
      Category.find_each(&:update_tools_count!)
      puts "✅ 分类计数更新完成"
    else
      puts "⚠️  未找到工具数据"
    end
    
    puts "\n🎉 导入完成！"
    puts "📈 当前数据库统计:"
    puts "  - 分类数量: #{Category.count}"
    puts "  - 一级分类: #{Category.root_categories.count}"
    puts "  - 二级分类: #{Category.child_categories.count}"
    puts "  - 工具数量: #{Tool.count}"
  end
  
  desc "清空所有工具数据（危险操作）"
  task clear: :environment do
    print "⚠️  确定要删除所有工具吗？这个操作不可逆！(输入 YES 确认): "
    confirmation = STDIN.gets.chomp
    
    if confirmation == 'YES'
      count = Tool.count
      Tool.destroy_all
      Category.find_each(&:update_tools_count!)
      puts "✅ 已删除 #{count} 个工具"
    else
      puts "❌ 操作已取消"
    end
  end
  
  desc "导出所有工具数据到 YAML 文件"
  task export: :environment do
    output_file = Rails.root.join('db', 'data', 'tools_export.yml')
    
    data = {
      'categories' => Category.all.order(:parent_id, :name).map { |c|
        result = {
          'name' => c.name,
          'description' => c.description
        }
        result['parent'] = c.parent.name if c.parent.present?
        result
      },
      'tools' => Tool.all.map { |t|
        {
          'name' => t.name,
          'website_url' => t.website_url,
          'short_description' => t.short_description,
          'long_description' => t.long_description,
          'logo_url' => t.logo_url,
          'pricing_type' => t.pricing_type,
          'categories' => t.categories.pluck(:name)
        }
      }
    }
    
    File.write(output_file, data.to_yaml)
    puts "✅ 已导出 #{Tool.count} 个工具、#{Category.count} 个分类到: #{output_file}"
    puts "📁 分类结构:"
    puts "  - 一级分类: #{Category.root_categories.count}"
    puts "  - 二级分类: #{Category.child_categories.count}"
  end
  
  desc "显示工具导入帮助信息"
  task help: :environment do
    puts <<~HELP
      
      📖 工具数据管理帮助
      ==================
      
      可用命令:
      
      1. 导入工具数据
         rake tools:import
         - 从 db/data/tools.yml 导入工具数据
         - 如果工具已存在，会更新其信息
         - 自动创建不存在的分类
      
      2. 导出工具数据
         rake tools:export
         - 将当前数据库的工具导出到 db/data/tools_export.yml
         - 用于备份或迁移数据
      
      3. 清空工具数据
         rake tools:clear
         - 删除所有工具（需要确认）
         - 分类不会被删除
      
      4. 显示帮助
         rake tools:help
         - 显示此帮助信息
      
      文件格式:
      
      YAML 文件应包含以下结构:
      
      categories:
        - name: "分类名称"
          description: "分类描述"
      
      tools:
        - name: "工具名称"
          website_url: "https://example.com"
          short_description: "简短描述（最多150字符）"
          long_description: "详细描述（可选）"
          logo_url: "图片URL（可选）"
          pricing_type: "Free/Freemium/Paid"
          categories:
            - "分类1"
            - "分类2"
      
      示例:
      
      tools:
        - name: "法小兔"
          website_url: "https://faxiaotu.com"
          short_description: "智能法律文书生成工具"
          pricing_type: "Freemium"
          categories:
            - "法律文书生成"
      
      注意事项:
      
      1. website_url 必须是完整的 URL（包含 http:// 或 https://）
      2. short_description 不能超过 150 个字符
      3. pricing_type 只能是 Free、Freemium 或 Paid
      4. categories 中的分类名称必须在数据库中存在
      5. 如果不提供 logo_url，系统会尝试从网站自动提取
      
    HELP
  end
end
