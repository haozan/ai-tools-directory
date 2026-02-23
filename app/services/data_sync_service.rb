# DataSyncService - 数据同步服务
# 用于将本地数据库的 Category 和 Tool 数据完全同步到生产环境
# 完全同步模式：会删除生产环境中不在 YAML 文件里的数据
class DataSyncService < ApplicationService
  def initialize
    @results = {
      categories: { created: 0, updated: 0, deleted: 0, errors: [] },
      tools: { created: 0, updated: 0, deleted: 0, errors: [] },
      associations: { created: 0, errors: [] }
    }
  end

  def call
    ActiveRecord::Base.transaction do
      data_file = Rails.root.join('db', 'data', 'tools.yml')
      
      unless File.exist?(data_file)
        @results[:error] = "数据文件不存在: #{data_file}"
        return @results
      end

      @data = YAML.load_file(data_file)
      
      # 按顺序执行同步
      sync_categories_two_pass  # 两次遍历：先根分类，后子分类
      sync_tools
      sync_tool_categories
      
      # 删除不在 YAML 中的数据（完全同步模式）
      delete_obsolete_tools
      delete_obsolete_categories
    end

    @results
  rescue StandardError => e
    @results[:error] = e.message
    @results
  end

  private

  def sync_categories_two_pass
    categories_data = @data['categories'] || []
    
    # First pass: sync root categories (no parent)
    root_categories = categories_data.select { |cat| cat['parent'].blank? }
    root_categories.each do |cat_data|
      sync_category(cat_data)
    end
    
    # Second pass: sync child categories (with parent)
    child_categories = categories_data.select { |cat| cat['parent'].present? }
    child_categories.each do |cat_data|
      sync_category(cat_data)
    end
  end

  def sync_categories
    categories_data = @data['categories'] || []
    categories_data.each do |cat_data|
      sync_category(cat_data)
    end
  end

  def sync_tools
    tools_data = @data['tools'] || []
    tools_data.each do |tool_data|
      sync_tool(tool_data)
    end
  end

  def sync_tool_categories
    tools_data = @data['tools'] || []
    tools_data.each do |tool_data|
      sync_tool_category_associations(tool_data)
    end
  end

  def sync_category(cat_data)
    category = Category.find_or_initialize_by(name: cat_data['name'])
    
    if category.new_record?
      category.assign_attributes(
        description: cat_data['description'],
        parent_id: find_parent_category_id(cat_data['parent']),
        position: cat_data['position']
      )
      
      if category.save
        @results[:categories][:created] += 1
      else
        @results[:categories][:errors] << "分类 #{cat_data['name']}: #{category.errors.full_messages.join(', ')}"
      end
    else
      category.update(
        description: cat_data['description'],
        parent_id: find_parent_category_id(cat_data['parent']),
        position: cat_data['position']
      )
      @results[:categories][:updated] += 1
    end
  end

  def sync_tool(tool_data)
    tool = Tool.find_or_initialize_by(website_url: tool_data['website_url'])
    
    if tool.new_record?
      tool.assign_attributes(
        name: tool_data['name'],
        short_description: tool_data['short_description'],
        long_description: tool_data['long_description'],
        logo_url: tool_data['logo_url'],
        featured: tool_data['featured'] || false
      )
      
      if tool.save
        @results[:tools][:created] += 1
      else
        @results[:tools][:errors] << "工具 #{tool_data['name']}: #{tool.errors.full_messages.join(', ')}"
      end
    else
      tool.update(
        name: tool_data['name'],
        short_description: tool_data['short_description'],
        long_description: tool_data['long_description'],
        logo_url: tool_data['logo_url'],
        featured: tool_data['featured'] || false
      )
      @results[:tools][:updated] += 1
    end
  end

  def sync_tool_category_associations(tool_data)
    tool = Tool.find_by(website_url: tool_data['website_url'])
    return unless tool

    # 清除该工具的所有现有关联
    tool.tool_categories.destroy_all

    # 重新创建关联
    categories = tool_data['categories'] || []
    categories.each do |category_name|
      category = Category.find_by(name: category_name)
      next unless category

      if ToolCategory.create(tool: tool, category: category)
        @results[:associations][:created] += 1
      else
        @results[:associations][:errors] << "关联失败: #{tool.name} <-> #{category.name}"
      end
    end

    # 更新分类工具数量
    tool.categories.each(&:update_tools_count!)
  end

  def delete_obsolete_tools
    # 获取 YAML 中所有工具的 website_url
    yaml_tool_urls = (@data['tools'] || []).map { |t| t['website_url'] }.compact
    
    # 查找并删除不在 YAML 中的工具
    obsolete_tools = Tool.where.not(website_url: yaml_tool_urls)
    deleted_count = obsolete_tools.count
    
    obsolete_tools.destroy_all
    
    @results[:tools][:deleted] = deleted_count
  end

  def delete_obsolete_categories
    # 获取 YAML 中所有分类的名称
    yaml_category_names = (@data['categories'] || []).map { |c| c['name'] }.compact
    
    # 查找并删除不在 YAML 中的分类
    obsolete_categories = Category.where.not(name: yaml_category_names)
    deleted_count = obsolete_categories.count
    
    obsolete_categories.destroy_all
    
    @results[:categories][:deleted] = deleted_count
    
    # 更新所有分类的工具数量
    Category.find_each(&:update_tools_count!)
  end

  def find_parent_category_id(parent_name)
    return nil if parent_name.blank?
    
    parent = Category.find_by(name: parent_name)
    parent&.id
  end
end
