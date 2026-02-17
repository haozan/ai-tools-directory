# 分类层级和工具管理指南

本文档说明如何在代码中修改分类层级和添加工具。

---

## 一、分类层级管理

### 1. 创建一级分类（根分类）

```ruby
# 方法1：使用 rails console
rails console

# 创建一级分类
category = Category.create!(
  name: "AI工具",
  description: "人工智能相关工具",
  parent_id: nil  # nil 表示一级分类
)

# 方法2：使用 rails runner
rails runner "Category.create!(name: 'AI工具', description: '人工智能相关工具', parent_id: nil)"
```

### 2. 创建二级分类（子分类）

```ruby
# 方法1：通过父分类对象创建
parent = Category.find_by(name: "通用大模型")
child = parent.children.create!(
  name: "对话助手",
  description: "AI对话助手工具"
)

# 方法2：直接指定 parent_id
parent = Category.find_by(name: "通用大模型")
Category.create!(
  name: "对话助手",
  description: "AI对话助手工具",
  parent_id: parent.id
)

# 方法3：一行命令
rails runner "Category.create!(name: '对话助手', parent_id: Category.find_by(name: '通用大模型').id)"
```

### 3. 修改分类层级

```ruby
# 将一级分类改为二级分类
category = Category.find_by(name: "某分类")
parent = Category.find_by(name: "新父分类")
category.update!(parent_id: parent.id)

# 将二级分类改为一级分类
category = Category.find_by(name: "某分类")
category.update!(parent_id: nil)

# 修改二级分类的父分类
category = Category.find_by(name: "某分类")
new_parent = Category.find_by(name: "新父分类")
category.update!(parent_id: new_parent.id)
```

### 4. 查看分类层级

```ruby
# 查看所有一级分类
Category.root_categories.each do |cat|
  puts cat.name
end

# 查看某个分类的子分类
parent = Category.find_by(name: "通用大模型")
parent.children.each do |child|
  puts "  - #{child.name}"
end

# 查看分类的完整路径
category = Category.find_by(name: "对话助手")
puts category.full_path  # 输出：通用大模型 > 对话助手
```

### 5. 设置分类显示顺序

```ruby
# 设置分类为第一位（position = 0）
category = Category.find_by(name: "通用大模型")
category.update!(position: 0)

# 设置分类为第二位（position = 1）
category = Category.find_by(name: "法律大数据")
category.update!(position: 1)

# 其他分类不设置 position（保持 nil），会按工具数量排序
Category.where.not(name: ["通用大模型", "法律大数据"]).update_all(position: nil)
```

---

## 二、工具管理

### 1. 创建工具（单个）

```ruby
# 方法1：完整创建
tool = Tool.create!(
  name: "ChatGPT",
  website_url: "https://chat.openai.com",
  short_description: "OpenAI开发的AI对话助手",
  long_description: "详细的工具描述...",
  pricing_type: "Freemium"  # 可选值：Free, Freemium, Paid
)

# 方法2：一行命令
rails runner "Tool.create!(name: 'ChatGPT', website_url: 'https://chat.openai.com', short_description: 'OpenAI开发的AI对话助手', pricing_type: 'Freemium')"
```

### 2. 关联工具到分类

```ruby
# 方法1：通过工具对象
tool = Tool.find_by(name: "ChatGPT")
category = Category.find_by(name: "对话助手")
tool.categories << category

# 方法2：通过分类对象
category = Category.find_by(name: "对话助手")
tool = Tool.find_by(name: "ChatGPT")
category.tools << tool

# 方法3：关联到多个分类
tool = Tool.find_by(name: "ChatGPT")
categories = Category.where(name: ["对话助手", "通用大模型"])
tool.categories = categories

# 方法4：创建时直接关联
category = Category.find_by(name: "对话助手")
tool = Tool.create!(
  name: "Claude",
  website_url: "https://claude.ai",
  short_description: "Anthropic开发的AI助手",
  pricing_type: "Freemium",
  categories: [category]
)
```

### 3. 移动工具到其他分类

```ruby
# 清除原有分类，添加新分类
tool = Tool.find_by(name: "ChatGPT")
old_category = Category.find_by(name: "通用大模型")
new_category = Category.find_by(name: "对话助手")

# 移除旧分类
tool.categories.delete(old_category)

# 添加新分类
tool.categories << new_category

# 或者直接替换所有分类
tool.categories = [new_category]
```

### 4. 批量移动工具

```ruby
# 将多个工具从一个分类移到另一个分类
source_category = Category.find_by(name: "通用大模型")
target_category = Category.find_by(name: "对话助手")
tool_names = ["ChatGPT", "Claude", "Gemini"]

tool_names.each do |name|
  tool = Tool.find_by(name: name)
  next unless tool
  
  tool.categories.delete(source_category)
  tool.categories << target_category unless tool.categories.include?(target_category)
  puts "已移动: #{name}"
end
```

### 5. 上传工具 Logo

```ruby
# 从本地文件上传
tool = Tool.find_by(name: "ChatGPT")
tool.logo.attach(
  io: File.open('path/to/logo.png'),
  filename: 'chatgpt_logo.png',
  content_type: 'image/png'
)

# 从 URL 下载并上传
require 'open-uri'
tool = Tool.find_by(name: "ChatGPT")
tool.logo.attach(
  io: URI.open('https://example.com/logo.png'),
  filename: 'chatgpt_logo.png',
  content_type: 'image/png'
)

# 一行命令示例
rails runner "tool = Tool.find_by(name: 'ChatGPT'); tool.logo.attach(io: File.open('tmp/logo.png'), filename: 'logo.png', content_type: 'image/png')"
```

### 6. 更新工具计数

```ruby
# 更新单个分类的工具计数
category = Category.find_by(name: "对话助手")
category.update_tools_count!

# 更新所有分类的工具计数
Category.find_each do |category|
  category.update_tools_count!
end
```

---

## 三、使用 YAML 文件批量管理

### 1. YAML 文件格式

创建文件 `db/data/my_tools.yml`：

```yaml
categories:
  - name: "AI助手"
    description: "AI对话助手工具"
    parent: null  # 一级分类
  
  - name: "文本生成"
    description: "AI文本生成工具"
    parent: "AI助手"  # 二级分类，父分类为 "AI助手"

tools:
  - name: "ChatGPT"
    website_url: "https://chat.openai.com"
    short_description: "OpenAI开发的AI对话助手"
    pricing_type: "Freemium"
    categories:
      - "AI助手"
  
  - name: "Claude"
    website_url: "https://claude.ai"
    short_description: "Anthropic开发的AI助手"
    pricing_type: "Freemium"
    categories:
      - "AI助手"
      - "文本生成"
```

### 2. 导入 YAML 文件

```bash
# 导入工具和分类
rake tools:import_yaml FILE=db/data/my_tools.yml

# 导出现有数据到 YAML
rake tools:export_yaml
```

---

## 四、常用命令速查

### 分类操作

```bash
# 创建一级分类
rails runner "Category.create!(name: 'AI工具', parent_id: nil)"

# 创建二级分类
rails runner "Category.create!(name: '对话助手', parent_id: Category.find_by(name: 'AI工具').id)"

# 修改分类层级
rails runner "Category.find_by(name: '对话助手').update!(parent_id: Category.find_by(name: '新父分类').id)"

# 设置分类顺序
rails runner "Category.find_by(name: '通用大模型').update!(position: 0)"

# 查看所有一级分类
rails runner "Category.root_categories.each { |c| puts c.name }"
```

### 工具操作

```bash
# 创建工具
rails runner "Tool.create!(name: 'ChatGPT', website_url: 'https://chat.openai.com', short_description: 'AI助手', pricing_type: 'Freemium')"

# 关联工具到分类
rails runner "Tool.find_by(name: 'ChatGPT').categories << Category.find_by(name: '对话助手')"

# 上传 logo
rails runner "tool = Tool.find_by(name: 'ChatGPT'); tool.logo.attach(io: File.open('tmp/logo.png'), filename: 'logo.png', content_type: 'image/png')"

# 查看工具所属分类
rails runner "puts Tool.find_by(name: 'ChatGPT').categories.map(&:name).join(', ')"
```

---

## 五、完整示例

### 示例1：创建完整的分类层级和工具

```ruby
# 进入 Rails console
rails console

# 1. 创建一级分类
ai_category = Category.create!(
  name: "AI工具集",
  description: "各类AI工具",
  parent_id: nil
)

# 2. 创建二级分类
chat_category = ai_category.children.create!(
  name: "对话助手",
  description: "AI对话助手"
)

# 3. 创建工具并关联到二级分类
tool = Tool.create!(
  name: "ChatGPT",
  website_url: "https://chat.openai.com",
  short_description: "OpenAI的AI助手",
  pricing_type: "Freemium"
)

# 4. 关联工具到分类
tool.categories << chat_category

# 5. 上传 logo（如果有）
tool.logo.attach(
  io: File.open('tmp/chatgpt_logo.png'),
  filename: 'chatgpt_logo.png',
  content_type: 'image/png'
)

# 6. 更新分类工具计数
chat_category.update_tools_count!
ai_category.update_tools_count!

puts "创建完成！"
puts "工具链接: /tools/#{tool.slug}"
puts "分类链接: /categories/#{chat_category.slug}"
```

### 示例2：批量修改分类结构

```ruby
rails console

# 场景：将"AI大模型"改为"通用大模型"，并创建两个子分类

# 1. 重命名父分类
parent = Category.find_by(name: "AI大模型")
parent.update!(name: "通用大模型")

# 2. 创建子分类
chat_cat = parent.children.create!(name: "对话助手")
api_cat = parent.children.create!(name: "API聚合")

# 3. 批量移动工具
chat_tools = ["ChatGPT", "Claude", "Kimi", "文心一言"]
chat_tools.each do |name|
  tool = Tool.find_by(name: name)
  next unless tool
  
  tool.categories.delete(parent)
  tool.categories << chat_cat
end

# 4. 更新所有计数
[parent, chat_cat, api_cat].each(&:update_tools_count!)

puts "分类结构更新完成！"
```

---

## 六、注意事项

### 1. 字段验证

- `name`: 必填，同一父分类下不能重复
- `website_url`: 必填，必须是有效的 URL
- `pricing_type`: 必须是 `Free`, `Freemium`, 或 `Paid`
- `short_description`: 最多 150 字符

### 2. 分类层级限制

- 目前支持两级分类（一级分类 + 二级分类）
- 不能创建循环引用（子分类不能成为父分类的父分类）

### 3. Slug 生成

- 分类和工具都会自动生成 slug（URL 友好的标识符）
- 中文名称会转换为拼音 slug
- 可以手动指定 slug：`tool.update_column(:slug, 'custom-slug')`

### 4. Logo 上传

- 支持的格式：PNG, JPG, GIF
- 使用 ActiveStorage 存储
- 上传前需要确保文件存在

### 5. 工具计数

- 每次修改工具关联后，建议运行 `category.update_tools_count!`
- 分类页面显示的工具数量基于 `tools_count` 字段

---

## 七、故障排查

### 问题1：找不到分类或工具

```ruby
# 检查分类是否存在
Category.where("name LIKE ?", "%关键词%").pluck(:name)

# 检查工具是否存在
Tool.where("name LIKE ?", "%关键词%").pluck(:name)
```

### 问题2：工具计数不正确

```ruby
# 手动重建所有计数
Category.find_each do |category|
  count = category.tools.count
  category.update_column(:tools_count, count)
  puts "#{category.name}: #{count}"
end
```

### 问题3：分类层级混乱

```ruby
# 查看所有分类的层级结构
Category.root_categories.each do |parent|
  puts parent.name
  parent.children.each do |child|
    puts "  └─ #{child.name} (parent_id: #{child.parent_id})"
  end
end
```

---

如有其他问题，可以查看：
- 模型文件：`app/models/category.rb`, `app/models/tool.rb`
- Rake 任务：`lib/tasks/tools.rake`
- 迁移文件：`db/migrate/`
