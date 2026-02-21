# 数据同步功能使用说明

## 功能概述

在后台管理系统中添加了一键数据同步功能，可以将本地开发环境的分类和工具数据同步到生产环境。

## 快速使用指南

### 部署前准备

1. **导出当前数据**（在本地开发环境执行）：

```bash
rails runner tmp/export_current_data.rb
```

这会将当前数据库中的所有分类和工具导出到 `db/data/kulawyer_tools.yml` 文件。

2. **提交代码**：

```bash
git add db/data/kulawyer_tools.yml
git commit -m "Update tools database for production sync"
git push
```

### 部署后同步

部署到生产环境后，只需在后台管理界面点击 "Sync Data" 按钮即可一键同步数据。

## 详细使用方法

### 1. 导出本地数据

在部署到生产环境之前，需要先导出本地数据到 YAML 文件：

```bash
rails runner tmp/export_current_data.rb
```

或者使用内置的脚本：

```ruby
# 在 rails console 中执行
data = {
  'categories' => [],
  'tools' => []
}

Category.order(:position, :id).each do |category|
  cat_data = {
    'name' => category.name,
    'description' => category.description,
    'position' => category.position
  }
  cat_data['parent'] = category.parent.name if category.parent.present?
  data['categories'] << cat_data
end

Tool.order(:id).each do |tool|
  tool_data = {
    'name' => tool.name,
    'website_url' => tool.website_url,
    'short_description' => tool.short_description,
    'long_description' => tool.long_description,
    'categories' => tool.categories.pluck(:name)
  }
  data['tools'] << tool_data
end

File.open(Rails.root.join('db', 'data', 'kulawyer_tools.yml'), 'w') do |file|
  file.write(YAML.dump(data))
end
```

### 2. 部署到生产环境

确保 `db/data/kulawyer_tools.yml` 文件已经更新并提交到版本控制系统，然后部署到生产环境。

### 3. 在生产环境同步数据

部署完成后，在生产环境执行以下步骤：

1. 访问生产环境的后台管理地址（例如：`https://your-domain.com/admin`）
2. 使用管理员账号登录
3. 进入 Dashboard 页面（登录后默认页面）
4. 在 "Quick Actions" 区域找到 **Sync Data** 按钮（紫色图标）
5. 点击按钮，系统会弹出确认对话框
6. 确认同步操作
7. 系统会自动读取 `db/data/kulawyer_tools.yml` 文件并同步数据
8. 同步完成后，页面顶部会显示同步结果统计

**同步结果示例：**
```
数据同步成功！分类: 新增0个, 更新23个, 删除0个; 工具: 新增0个, 更新65个, 删除5个; 关联: 新增0个
```

## 同步逻辑

**完全同步模式**：

- **分类同步**：按名称查找，不存在则创建，存在则更新，**删除不在 YAML 中的分类**
- **工具同步**：按 website_url 查找，不存在则创建，存在则更新，**删除不在 YAML 中的工具**
- **关联同步**：清除现有关联，重新创建工具与分类的关联关系
- **计数更新**：自动更新所有分类的 tools_count 字段

## 注意事项

1. **完全同步模式**：同步操作会删除生产环境中不在 YAML 文件里的工具和分类，请确保 YAML 文件包含所有需要保留的数据
2. 确保 YAML 文件格式正确，避免同步失败
3. 同步操作会在事务中执行，如果出现错误会自动回滚
4. 同步结果会显示在 Flash 消息中，包括成功和失败的详细信息
5. **建议在同步前备份生产数据库**，以防意外删除

## 文件位置

- 数据文件：`db/data/kulawyer_tools.yml`
- 服务类：`app/services/data_sync_service.rb`
- 控制器：`app/controllers/admin/dashboard_controller.rb`
- 视图：`app/views/admin/dashboard/index.html.erb`
