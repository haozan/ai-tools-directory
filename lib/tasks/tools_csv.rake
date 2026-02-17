namespace :tools do
  desc "从 CSV 文件导入工具数据"
  task import_csv: :environment do
    require 'csv'
    
    file_path = Rails.root.join('db', 'data', 'tools.csv')
    
    unless File.exist?(file_path)
      puts "❌ 文件不存在: #{file_path}"
      puts "请先创建 db/data/tools.csv 文件"
      puts "可以参考 db/data/tools_template.csv 模板"
      exit 1
    end
    
    puts "📂 正在读取文件: #{file_path}"
    
    success_count = 0
    skip_count = 0
    error_count = 0
    
    CSV.foreach(file_path, headers: true, encoding: 'UTF-8') do |row|
      begin
        # 跳过空行
        next if row['name'].blank?
        
        # 查找或创建工具
        tool = Tool.find_or_initialize_by(name: row['name'].strip)
        
        # 如果工具已存在且没有变化，跳过
        if !tool.new_record? && 
           tool.website_url == row['website_url']&.strip && 
           tool.short_description == row['short_description']&.strip
          puts "  ⏭️  跳过（已存在且无变化）: #{tool.name}"
          skip_count += 1
          next
        end
        
        # 更新属性
        tool.website_url = row['website_url']&.strip
        tool.short_description = row['short_description']&.strip
        tool.long_description = row['long_description']&.strip if row['long_description'].present?
        tool.logo_url = row['logo_url']&.strip if row['logo_url'].present?
        tool.pricing_type = row['pricing_type']&.strip
        
        if tool.save
          # 关联分类（逗号分隔）
          if row['categories'].present?
            category_names = row['categories'].split(',').map(&:strip)
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
        puts "  ❌ 处理失败: #{row['name']} - #{e.message}"
        error_count += 1
      end
    end
    
    puts "\n" + "="*60
    puts "📊 导入统计:"
    puts "  ✅ 成功: #{success_count} 个"
    puts "  ⏭️  跳过: #{skip_count} 个"
    puts "  ❌ 失败: #{error_count} 个"
    puts "="*60
    
    # 更新分类计数
    puts "\n🔄 正在更新分类工具计数..."
    Category.find_each(&:update_tools_count!)
    puts "✅ 分类计数更新完成"
    
    puts "\n🎉 导入完成！"
    puts "📈 当前数据库统计:"
    puts "  - 分类数量: #{Category.count}"
    puts "  - 工具数量: #{Tool.count}"
  end
  
  desc "导出所有工具数据到 CSV 文件"
  task export_csv: :environment do
    require 'csv'
    
    output_file = Rails.root.join('db', 'data', 'tools_export.csv')
    
    CSV.open(output_file, 'w', encoding: 'UTF-8') do |csv|
      # 写入表头
      csv << ['name', 'website_url', 'short_description', 'long_description', 'logo_url', 'pricing_type', 'categories']
      
      # 写入数据
      Tool.find_each do |tool|
        csv << [
          tool.name,
          tool.website_url,
          tool.short_description,
          tool.long_description,
          tool.logo_url,
          tool.pricing_type,
          tool.categories.pluck(:name).join(',')
        ]
      end
    end
    
    puts "✅ 已导出 #{Tool.count} 个工具到: #{output_file}"
    puts "💡 你可以用 Excel 或 Google Sheets 打开此文件进行编辑"
  end
end
