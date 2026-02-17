# 工具批量管理完整方案

## 🎯 三种方案对比

| 特性 | YAML 方案 ⭐⭐⭐⭐⭐ | CSV 方案 ⭐⭐⭐⭐ | Seeds 方案 ⭐⭐⭐ |
|------|---------|---------|---------|
| 易读性 | ✅ 极好 | ✅ 好 | ⚠️ 一般 |
| 支持注释 | ✅ 是 | ❌ 否 | ✅ 是 |
| Excel 编辑 | ❌ 否 | ✅ 是 | ❌ 否 |
| 批量导入 | ✅ 极快 | ✅ 快 | ✅ 快 |
| 增量更新 | ✅ 支持 | ✅ 支持 | ⚠️ 有限 |
| 适合人群 | 技术人员 | 所有人 | 开发人员 |

## 📁 已创建的文件

```
db/data/
├── README.md                 # 完整使用文档
├── tools.yml                 # YAML 格式数据文件（含示例）
├── tools_template.csv        # CSV 模板文件
├── tools_export.yml          # YAML 导出文件（自动生成）
└── tools_export.csv          # CSV 导出文件（自动生成）

lib/tasks/
├── tools.rake                # YAML 导入/导出任务
└── tools_csv.rake            # CSV 导入/导出任务
```

## 🚀 快速开始

### 方案 1: YAML 文件（推荐）

**适合场景：** 
- 技术人员维护
- 需要添加注释
- 版本控制友好

**步骤：**

```bash
# 1. 编辑 YAML 文件
vim db/data/tools.yml

# 2. 导入数据
rake tools:import

# 3. 查看结果
# 访问 http://localhost:3000/tools
```

**YAML 文件示例：**
```yaml
tools:
  - name: "法小兔"
    website_url: "https://faxiaotu.com"
    short_description: "智能法律文书生成工具"
    long_description: "详细描述..."
    pricing_type: "Freemium"
    categories:
      - "法律文书生成"
      - "合同审查"
```

### 方案 2: CSV 文件

**适合场景：**
- 非技术人员维护
- 使用 Excel/Google Sheets 编辑
- 大量数据录入

**步骤：**

```bash
# 1. 导出当前数据作为模板
rake tools:export_csv

# 2. 用 Excel 打开 tools_export.csv
# 3. 添加或修改工具数据
# 4. 保存为 tools.csv

# 5. 导入数据
rake tools:import_csv
```

**CSV 格式：**
```csv
name,website_url,short_description,long_description,logo_url,pricing_type,categories
法小兔,https://faxiaotu.com,智能法律文书生成,详细描述,,Freemium,"法律文书生成,合同审查"
```

### 方案 3: 直接修改 Seeds

**适合场景：**
- 开发环境初始化
- 一次性数据导入

**步骤：**

```ruby
# 编辑 db/seeds.rb
tools_data = [
  {
    name: "法小兔",
    website_url: "https://faxiaotu.com",
    short_description: "智能法律文书生成工具",
    pricing_type: "Freemium",
    categories: ["法律文书生成", "合同审查"]
  }
]

# 运行 seeds
rake db:seed
```

## 🛠️ 所有可用命令

### YAML 相关

```bash
# 导入工具（从 db/data/tools.yml）
rake tools:import

# 导出工具（到 db/data/tools_export.yml）
rake tools:export

# 清空所有工具（需输入 YES 确认）
rake tools:clear

# 显示帮助信息
rake tools:help
```

### CSV 相关

```bash
# 从 CSV 导入（db/data/tools.csv）
rake tools:import_csv

# 导出到 CSV（db/data/tools_export.csv）
rake tools:export_csv
```

### 其他命令

```bash
# 查看当前工具数量
rails runner "puts Tool.count"

# 查看所有分类
rails runner "Category.all.each { |c| puts c.name }"

# 重置数据库并导入
rake db:reset && rake tools:import
```

## 💡 最佳实践

### 1. 批量添加工具（100+ 个）

**推荐方案：CSV**

```bash
# 1. 导出现有数据
rake tools:export_csv

# 2. 用 Excel 打开，在底部批量添加
# 3. 保存为 tools.csv

# 4. 导入数据
rake tools:import_csv
```

### 2. 定期维护更新

**推荐方案：YAML**

```bash
# 1. 编辑 tools.yml
# 2. 运行导入（会自动更新已存在的工具）
rake tools:import
```

### 3. 数据备份

```bash
# 定期导出备份
rake tools:export
rake tools:export_csv

# 提交到 Git（YAML 更友好）
git add db/data/tools.yml
git commit -m "Update tools data"
```

### 4. 团队协作

**方案 A：技术团队**
- 使用 YAML + Git 版本控制
- Pull Request 审核变更

**方案 B：混合团队**
- 运营人员用 CSV + Excel
- 开发人员定期导出并提交到 Git

## 📊 数据字段说明

| 字段 | 必填 | 类型 | 说明 | 示例 |
|------|------|------|------|------|
| name | ✅ | 字符串 | 工具名称（唯一） | "法小兔" |
| website_url | ✅ | URL | 官网地址（完整URL） | "https://faxiaotu.com" |
| short_description | ✅ | 字符串 | 简短描述（≤150字符） | "智能法律文书生成工具" |
| long_description | ❌ | 文本 | 详细描述 | "法小兔是一款..." |
| logo_url | ❌ | URL | Logo图片URL | "https://..." |
| pricing_type | ✅ | 枚举 | Free/Freemium/Paid | "Freemium" |
| categories | ✅ | 数组 | 分类列表（≥1个） | ["法律文书生成"] |

## 🔄 实际工作流程

### 场景 1: 新项目初始化

```bash
# 1. 编辑 tools.yml，添加初始数据
vim db/data/tools.yml

# 2. 创建数据库
rake db:create db:migrate

# 3. 导入数据
rake tools:import

# 4. 启动项目
bin/dev
```

### 场景 2: 添加 50 个新工具

```bash
# 1. 导出现有数据
rake tools:export_csv

# 2. Excel 中添加 50 个工具
# 保存为 tools.csv

# 3. 导入（相同名称会跳过或更新）
rake tools:import_csv

# 4. 验证导入结果
rails runner "puts '工具总数: ' + Tool.count.to_s"
```

### 场景 3: 更新工具信息

```bash
# 方法 1: 直接修改 YAML
vim db/data/tools.yml
rake tools:import

# 方法 2: 通过管理后台
# 访问 /admin/tools

# 方法 3: 导出-编辑-导入
rake tools:export_csv
# 用 Excel 修改
rake tools:import_csv
```

### 场景 4: 数据迁移

```bash
# 从旧系统导出
rake tools:export_csv

# 复制文件到新系统
scp db/data/tools_export.csv new_server:/path/to/app/db/data/tools.csv

# 新系统导入
ssh new_server
cd /path/to/app
rake tools:import_csv
```

## 🐛 常见问题

### Q1: 导入时出现 "website_url is invalid"

**原因：** URL 格式不正确

**解决：**
```yaml
# ❌ 错误
website_url: "faxiaotu.com"
website_url: "www.faxiaotu.com"

# ✅ 正确
website_url: "https://faxiaotu.com"
website_url: "http://faxiaotu.com"
```

### Q2: short_description 太长

**原因：** 描述超过 150 字符

**解决：**
- 缩短描述
- 详细内容放到 `long_description`

### Q3: 分类不存在

**YAML 导入：** 会自动创建分类
```yaml
categories:
  - name: "新分类"
    description: "分类描述"
```

**CSV 导入：** 显示警告，需先创建分类
```bash
rails runner "Category.create!(name: '新分类', description: '描述')"
```

### Q4: 批量更新现有工具

**方法 1: 重新导入（推荐）**
```bash
# 修改 YAML/CSV 文件
rake tools:import  # 或 tools:import_csv
```

**方法 2: 清空后导入**
```bash
rake tools:clear    # 输入 YES 确认
rake tools:import
```

### Q5: Logo 图片处理

**选项 1: 提供 logo_url**
```yaml
logo_url: "https://example.com/logo.png"
```

**选项 2: 留空（自动提取）**
```yaml
logo_url: ""  # 系统会从 website_url 自动提取 OG image
```

**选项 3: 管理后台上传**
- 访问 `/admin/tools`
- 编辑工具
- 上传 Logo 文件

## 📈 性能建议

### 大量数据导入（1000+ 工具）

```bash
# 1. 临时禁用回调（可选）
# 编辑 app/models/tool.rb
# 注释掉 after_create :update_categories_count

# 2. 批量导入
rake tools:import

# 3. 手动更新计数
rake tools:update_counts

# 4. 恢复回调
```

### 定期维护

```bash
# 每周备份
0 0 * * 0 cd /path/to/app && rake tools:export

# 更新分类计数（如果不准确）
rails runner "Category.find_each(&:update_tools_count!)"
```

## 🎁 额外功能建议

### 1. 创建自定义导入脚本

```ruby
# lib/tasks/custom_import.rake
namespace :tools do
  desc "从 JSON API 导入工具"
  task import_from_api: :environment do
    require 'net/http'
    
    uri = URI('https://api.example.com/tools')
    response = Net::HTTP.get(uri)
    tools = JSON.parse(response)
    
    tools.each do |tool_data|
      # 导入逻辑
    end
  end
end
```

### 2. 定时自动更新

```ruby
# config/recurring.yml
update_tools:
  cron: "0 2 * * *"  # 每天凌晨2点
  class: "ToolsUpdateJob"
```

### 3. 数据验证脚本

```bash
# 验证所有工具 URL 可访问
rails runner "
  Tool.find_each do |tool|
    begin
      response = Net::HTTP.get_response(URI(tool.website_url))
      puts '✅ #{tool.name}: #{response.code}'
    rescue => e
      puts '❌ #{tool.name}: #{e.message}'
    end
  end
"
```

## 📚 更多资源

- 完整文档：`db/data/README.md`
- 工具模型：`app/models/tool.rb`
- 管理界面：`/admin/tools`
- API 文档：`/api/v1/tools`（如果启用）

## 🤝 贡献指南

如果你有更好的导入方案或建议，欢迎：
1. 修改相关 Rake 任务
2. 更新文档
3. 提交 Pull Request

---

**Kulawyer Team** 🎯
发现最佳法律AI工具
