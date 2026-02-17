# 工具数据管理指南

本目录用于管理 Kulawyer 平台的法律AI工具数据。

## 📁 文件说明

- `tools.yml` - YAML 格式的工具数据文件（推荐使用）
- `tools.csv` - CSV 格式的工具数据文件（Excel 可编辑）
- `tools_template.csv` - CSV 文件模板
- `tools_export.yml` - 导出的备份文件
- `tools_export.csv` - 导出的备份文件

## 🚀 快速开始

### 方案 1: 使用 YAML 文件（推荐）

**优点：** 结构清晰，支持注释，适合技术人员

1. **编辑工具数据**
   ```bash
   vim db/data/tools.yml
   ```

2. **导入数据**
   ```bash
   rake tools:import
   ```

3. **查看帮助**
   ```bash
   rake tools:help
   ```

### 方案 2: 使用 CSV 文件

**优点：** Excel/Google Sheets 可编辑，适合非技术人员

1. **创建 CSV 文件**
   - 复制 `tools_template.csv` 为 `tools.csv`
   - 用 Excel 或 Google Sheets 打开编辑

2. **导入数据**
   ```bash
   rake tools:import_csv
   ```

3. **导出数据**
   ```bash
   rake tools:export_csv
   ```

## 📝 数据格式说明

### YAML 格式

```yaml
categories:
  - name: "法律文书生成"
    description: "智能生成各类法律文书"

tools:
  - name: "法小兔"
    website_url: "https://faxiaotu.com"
    short_description: "智能法律文书生成工具"
    long_description: "详细描述..."
    logo_url: "https://example.com/logo.png"  # 可选
    pricing_type: "Freemium"  # Free/Freemium/Paid
    categories:
      - "法律文书生成"
      - "合同审查"
```

### CSV 格式

| name | website_url | short_description | long_description | logo_url | pricing_type | categories |
|------|-------------|-------------------|------------------|----------|--------------|------------|
| 法小兔 | https://faxiaotu.com | 智能法律文书生成 | 详细描述... | | Freemium | 法律文书生成,合同审查 |

**注意：**
- CSV 中的 `categories` 字段用逗号分隔多个分类
- 用 Excel 打开时确保编码为 UTF-8

## 🛠️ 可用命令

### YAML 相关

```bash
# 导入工具数据
rake tools:import

# 导出工具数据（备份）
rake tools:export

# 清空所有工具（需确认）
rake tools:clear

# 显示帮助
rake tools:help
```

### CSV 相关

```bash
# 从 CSV 导入
rake tools:import_csv

# 导出到 CSV
rake tools:export_csv
```

## ✅ 数据验证规则

1. **必填字段**
   - `name`: 工具名称（唯一）
   - `website_url`: 官网地址（必须是完整的 http/https URL）
   - `short_description`: 简短描述（最多 150 字符）
   - `pricing_type`: 价格类型（只能是 Free、Freemium 或 Paid）
   - `categories`: 至少一个分类

2. **可选字段**
   - `long_description`: 详细描述
   - `logo_url`: Logo 图片 URL（如不提供，系统会尝试自动提取）

3. **分类处理**
   - 如果分类不存在，YAML 导入会自动创建
   - CSV 导入会显示警告但不会创建

## 💡 最佳实践

### 批量添加工具

1. **准备数据**
   - 整理工具信息到 Excel
   - 确保所有 URL 完整（包含 https://）
   - 描述控制在 150 字符内

2. **导出模板**
   ```bash
   rake tools:export_csv
   ```

3. **编辑数据**
   - 用 Excel 打开 `tools_export.csv`
   - 在底部添加新工具
   - 保存为 `tools.csv`

4. **导入数据**
   ```bash
   rake tools:import_csv
   ```

### 定期备份

```bash
# 备份为 YAML
rake tools:export

# 备份为 CSV
rake tools:export_csv
```

## 🔄 工作流程示例

### 场景 1: 添加 50 个新工具

```bash
# 1. 导出现有数据到 CSV
rake tools:export_csv

# 2. 用 Excel 打开 tools_export.csv，添加 50 个工具

# 3. 保存为 tools.csv

# 4. 导入数据
rake tools:import_csv
```

### 场景 2: 更新工具信息

```bash
# 1. 导出数据
rake tools:export_csv

# 2. 在 Excel 中修改工具信息

# 3. 重新导入（相同名称的工具会被更新）
rake tools:import_csv
```

### 场景 3: 从头开始

```bash
# 1. 清空现有数据
rake tools:clear

# 2. 编辑 db/data/tools.yml

# 3. 导入数据
rake tools:import
```

## 🐛 常见问题

### Q: 导入失败怎么办？

A: 检查错误信息：
- URL 是否完整（包含 http:// 或 https://）
- 描述是否超过 150 字符
- pricing_type 是否正确（Free/Freemium/Paid）
- 分类名称是否存在

### Q: 如何批量修改工具？

A: 
1. 导出数据：`rake tools:export_csv`
2. 用 Excel 批量修改
3. 重新导入：`rake tools:import_csv`

### Q: 可以删除单个工具吗？

A: 可以通过管理后台删除，或者：
1. 导出数据
2. 在文件中删除对应行
3. 清空数据库：`rake tools:clear`
4. 重新导入

### Q: Logo 图片怎么处理？

A: 
1. 提供 `logo_url` 字段（外部图片链接）
2. 留空，系统会自动从网站提取
3. 通过管理后台手动上传

## 📊 示例数据

参考 `tools.yml` 中的示例数据，包含了法律文书生成、案例检索、合同审查等多个类别的工具。

## 🔗 相关链接

- 管理后台: `/admin/tools`
- 工具列表页: `/tools`
- 分类管理: `/admin/categories`
