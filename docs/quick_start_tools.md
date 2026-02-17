# 🚀 快速入门：5分钟添加工具

## 方法 1: 使用 YAML（推荐）⭐⭐⭐⭐⭐

### 步骤 1: 编辑 YAML 文件

打开 `db/data/tools.yml`，按照格式添加你的工具：

```yaml
tools:
  - name: "你的工具名称"
    website_url: "https://your-tool.com"
    short_description: "一句话描述这个工具（最多150字）"
    long_description: "详细介绍工具的功能和特点（可选）"
    logo_url: ""  # 留空会自动提取，或填写图片链接
    pricing_type: "Freemium"  # Free, Freemium 或 Paid
    categories:
      - "法律文书生成"  # 至少一个分类
      - "合同审查"      # 可以多个
```

### 步骤 2: 导入数据

```bash
rake tools:import
```

### 步骤 3: 查看结果

访问 http://localhost:3000/tools 查看你添加的工具！

---

## 方法 2: 使用 CSV（Excel 用户）⭐⭐⭐⭐

### 步骤 1: 导出模板

```bash
rake tools:export_csv
```

### 步骤 2: 用 Excel 编辑

1. 打开 `db/data/tools_export.csv`
2. 在底部添加新行
3. 填写工具信息
4. 保存为 `tools.csv`

**CSV 格式说明：**

| 列名 | 说明 | 示例 |
|------|------|------|
| name | 工具名称 | 法小兔 |
| website_url | 官网地址 | https://faxiaotu.com |
| short_description | 简短描述 | 智能法律文书生成工具 |
| long_description | 详细描述 | 法小兔是一款... |
| logo_url | Logo链接 | 留空或填URL |
| pricing_type | 价格类型 | Free/Freemium/Paid |
| categories | 分类 | 法律文书生成,合同审查 |

**注意：** categories 列用逗号分隔多个分类

### 步骤 3: 导入数据

```bash
rake tools:import_csv
```

---

## 🎯 实战示例

### 示例 1: 添加单个工具

**YAML 方式：**

```yaml
tools:
  - name: "智法AI"
    website_url: "https://zhifa-ai.com"
    short_description: "专业法律文书智能生成平台"
    pricing_type: "Paid"
    categories:
      - "法律文书生成"
```

```bash
rake tools:import
```

### 示例 2: 批量添加 10 个工具

**方法 A - YAML：** 在 `tools.yml` 中添加 10 个工具对象

**方法 B - CSV：** 
1. `rake tools:export_csv`
2. Excel 中添加 10 行
3. `rake tools:import_csv`

### 示例 3: 更新现有工具

修改 YAML 或 CSV 文件中对应工具的信息，重新导入即可：

```bash
rake tools:import  # 相同名称的工具会被更新
```

---

## ⚠️ 常见错误及解决

### 错误 1: "website_url is invalid"

**原因：** URL 必须包含 http:// 或 https://

```yaml
# ❌ 错误
website_url: "faxiaotu.com"

# ✅ 正确
website_url: "https://faxiaotu.com"
```

### 错误 2: "short_description is too long"

**原因：** 描述超过 150 字符

**解决：** 精简描述，详细内容写到 long_description

### 错误 3: "categories not found"

**YAML 导入：** 会自动创建分类（推荐）

**CSV 导入：** 需要先创建分类：

```bash
rails runner "Category.create!(name: '新分类', description: '描述')"
```

或者在 `tools.yml` 的 `categories` 部分添加：

```yaml
categories:
  - name: "新分类"
    description: "分类描述"
```

---

## 💡 高效技巧

### 技巧 1: 使用模板快速添加

复制现有工具的格式，修改内容即可：

```yaml
# 复制这个模板
- name: "工具名称"
  website_url: "https://"
  short_description: "描述"
  pricing_type: "Freemium"
  categories:
    - "分类1"
```

### 技巧 2: 批量操作

```bash
# 备份现有数据
rake tools:export

# 清空重新开始
rake tools:clear  # 输入 YES 确认

# 导入新数据
rake tools:import
```

### 技巧 3: 验证导入结果

```bash
# 查看工具数量
rails runner "puts Tool.count"

# 查看最新添加的工具
rails runner "Tool.last(5).each { |t| puts t.name }"

# 查看所有分类
rails runner "Category.all.each { |c| puts '#{c.name}: #{c.tools_count} 个工具' }"
```

---

## 📋 完整工作流程

### 场景：添加 50 个法律AI工具

**第1步：准备数据**
- 整理工具列表（Excel 或文档）
- 确认每个工具的官网、描述、价格类型

**第2步：选择方式**
- 技术人员 → YAML
- 其他人员 → CSV

**第3步：批量录入**

**YAML 方式：**
```bash
vim db/data/tools.yml
# 按格式添加 50 个工具
rake tools:import
```

**CSV 方式：**
```bash
rake tools:export_csv
# 用 Excel 打开，添加 50 行
# 保存为 tools.csv
rake tools:import_csv
```

**第4步：验证结果**
```bash
# 查看总数
rails runner "puts '总共 #{Tool.count} 个工具'"

# 启动项目查看
bin/dev
# 访问 http://localhost:3000/tools
```

**第5步：备份数据**
```bash
rake tools:export
git add db/data/tools.yml
git commit -m "Add 50 legal AI tools"
```

---

## 🔗 相关资源

- **详细文档：** `db/data/README.md`
- **完整指南：** `docs/tools_import_guide.md`
- **管理后台：** http://localhost:3000/admin/tools
- **工具列表：** http://localhost:3000/tools

---

## 📞 需要帮助？

```bash
# 查看帮助
rake tools:help

# 查看所有可用命令
rake -T tools

# 导出当前数据作为参考
rake tools:export
rake tools:export_csv
```

---

**开始添加你的第一个工具吧！** 🚀

只需要 3 步：
1. 编辑 `db/data/tools.yml`
2. 运行 `rake tools:import`
3. 访问 http://localhost:3000/tools

就是这么简单！
