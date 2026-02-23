# S3 配置和数据同步功能说明

## 概述

本文档说明了生产环境中的两个关键配置：
1. **ActiveStorage S3 配置** - 解决生产环境图标丢失问题
2. **数据同步功能** - 从 tools.yml 同步数据到数据库

## 一、ActiveStorage S3 配置

### 问题背景

在生产环境中，工具的图标会丢失，原因是：
- 开发环境使用本地存储（storage/ 目录）
- 本地存储的文件不会自动同步到生产环境
- 生产环境需要使用云存储（如 S3）来持久化存储文件

### 已完成的配置

#### 1. Gemfile
```ruby
gem "aws-sdk-s3", "~> 1.206"  # ✅ 已安装
```

#### 2. config/storage.yml
```yaml
storage_bucket:
  service: S3
  endpoint: <%= ENV.fetch("STORAGE_BUCKET_ENDPOINT", "") %>
  access_key_id: <%= ENV.fetch("STORAGE_BUCKET_ACCESS_KEY_ID", "") %>
  secret_access_key: <%= ENV.fetch("STORAGE_BUCKET_SECRET_ACCESS_KEY", "") %>
  region: <%= ENV.fetch("STORAGE_BUCKET_REGION", "") %>
  bucket: <%= ENV.fetch("STORAGE_BUCKET_NAME", "") %>
```

#### 3. config/application.yml
```yaml
# Storage bucket configuration, compatible with S3
STORAGE_BUCKET_ENDPOINT: '<%= ENV.fetch("CLACKY_STORAGE_BUCKET_ENDPOINT", '') %>'
STORAGE_BUCKET_ACCESS_KEY_ID: '<%= ENV.fetch("CLACKY_STORAGE_BUCKET_ACCESS_KEY_ID", '') %>'
STORAGE_BUCKET_SECRET_ACCESS_KEY: '<%= ENV.fetch("CLACKY_STORAGE_BUCKET_SECRET_ACCESS_KEY", '') %>'
STORAGE_BUCKET_REGION: '<%= ENV.fetch("CLACKY_STORAGE_BUCKET_REGION", '') %>'
STORAGE_BUCKET_NAME: '<%= ENV.fetch("CLACKY_STORAGE_BUCKET_NAME", '') %>'
```

#### 4. config/environments/production.rb
```ruby
# Store uploaded files on S3
config.active_storage.service = :storage_bucket  # ✅ 已从 :local 改为 :storage_bucket
```

### 使用说明

生产环境会自动从 Clacky 平台读取以下环境变量：
- `CLACKY_STORAGE_BUCKET_ENDPOINT`
- `CLACKY_STORAGE_BUCKET_ACCESS_KEY_ID`
- `CLACKY_STORAGE_BUCKET_SECRET_ACCESS_KEY`
- `CLACKY_STORAGE_BUCKET_REGION`
- `CLACKY_STORAGE_BUCKET_NAME`

这些变量会通过 `application.yml` 自动映射到 ActiveStorage 需要的变量名。

### 图标显示逻辑

Tool 模型有两种图标存储方式：
1. **logo_url** (字符串) - 外部 URL，直接使用
2. **logo** (ActiveStorage) - 上传的本地文件，在生产环境会存储到 S3

`Tool#logo_image_url` 方法会自动选择：
```ruby
def logo_image_url
  if logo.attached?
    Rails.application.routes.url_helpers.rails_blob_url(logo)
  else
    logo_url
  end
end
```

---

## 二、数据同步功能

### 功能说明

数据同步功能允许管理员从 `db/data/tools.yml` 文件同步数据到数据库。这是生产环境更新数据的主要方式。

### 核心改进 ✅

**修复前：** DataSyncService 使用错误的文件路径 `kulawyer_tools.yml`
**修复后：** 使用正确的文件路径 `tools.yml`

```ruby
# app/services/data_sync_service.rb (已更新)
def call
  ActiveRecord::Base.transaction do
    data_file = Rails.root.join('db', 'data', 'tools.yml')  # ✅ 修复
    
    unless File.exist?(data_file)
      @results[:error] = "数据文件不存在: #{data_file}"
      return @results
    end

    @data = YAML.load_file(data_file)
    
    # 按顺序执行同步
    sync_categories_two_pass  # ✅ 两次遍历：先根分类，后子分类
    sync_tools
    sync_tool_categories
    
    # 删除不在 YAML 中的数据（完全同步模式）
    delete_obsolete_tools
    delete_obsolete_categories
  end

  @results
end
```

### 两次遍历分类同步

为了正确处理父子分类关系，采用两次遍历策略：

```ruby
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
```

### 使用方式

#### 方式一：管理后台（推荐）

1. 登录管理后台: `/admin`
2. 在首页点击"同步数据"按钮
3. 确认同步操作
4. 查看同步结果（新增、更新、删除的数量）

#### 方式二：命令行

```bash
# 开发环境
rails runner 'DataSyncService.new.call'

# 生产环境
RAILS_ENV=production rails runner 'DataSyncService.new.call'
```

### 测试结果 ✅

```bash
$ rails runner 'results = DataSyncService.new.call; puts "Results: #{results.inspect}"'
Results: {:categories=>{:created=>0, :updated=>26, :deleted=>0, :errors=>[]}, 
          :tools=>{:created=>0, :updated=>75, :deleted=>0, :errors=>[]}, 
          :associations=>{:created=>65, :errors=>[]}}
```

---

## 三、完整工作流程

### 数据更新流程

1. **编辑 tools.yml**
   - 直接修改 `db/data/tools.yml` 文件
   - 添加/修改/删除分类或工具

2. **提交到 Git**
   ```bash
   git add db/data/tools.yml
   git commit -m "Update tools data"
   git push
   ```

3. **生产环境同步**
   - 登录管理后台
   - 点击"同步数据"按钮
   - 数据会从 tools.yml 同步到生产数据库

### 图标处理建议

**推荐方案：使用外部 URL**
- 在 tools.yml 中使用 `logo_url` 字段
- 指向稳定的外部图标服务（如 Unsplash、自建 CDN）
- 示例：
  ```yaml
  tools:
  - name: ClawHub
    logo_url: https://images.unsplash.com/xxx
  ```

**备选方案：上传到 S3**
- 通过管理后台编辑工具
- 上传图标文件
- 自动存储到 S3（生产环境）或本地（开发环境）

---

## 四、故障排查

### 同步按钮无效？

**症状：** 点击同步按钮后没有变化

**解决方案：** ✅ 已修复
- DataSyncService 现在使用正确的文件路径 `tools.yml`
- 添加了两次遍历分类同步逻辑

### 图标显示不出来？

**症状：** 生产环境工具图标无法显示

**检查清单：**
1. ✅ 确认 production.rb 配置为 `storage_bucket`
2. ✅ 确认环境变量 `CLACKY_STORAGE_BUCKET_*` 已设置
3. 确认 S3 bucket 权限配置正确（公开读取）
4. 优先使用 `logo_url` 字段指向外部 URL

### 分类层级关系错误？

**症状：** 子分类找不到父分类

**解决方案：** ✅ 已修复
- 使用 `sync_categories_two_pass` 方法
- 先创建所有根分类，再创建子分类

---

## 五、技术细节

### 同步逻辑

1. **幂等性**
   - 使用 `find_or_initialize_by` 避免重复创建
   - 支持多次运行同步而不会产生重复数据

2. **完全同步模式**
   - 删除不在 YAML 中的数据
   - 确保数据库与 YAML 文件保持一致

3. **事务保护**
   - 所有操作在一个事务中执行
   - 任何错误都会回滚所有更改

### 相关文件

- `app/services/data_sync_service.rb` - 同步服务实现
- `app/controllers/admin/dashboard_controller.rb` - 管理后台控制器
- `db/data/tools.yml` - 数据源文件
- `config/storage.yml` - ActiveStorage 配置
- `config/environments/production.rb` - 生产环境配置

---

## 六、总结

✅ **已完成的工作：**

1. 修复 DataSyncService 文件路径（kulawyer_tools.yml → tools.yml）
2. 添加两次遍历分类同步逻辑（处理父子关系）
3. 配置生产环境使用 S3 存储（storage_bucket）
4. 测试验证同步功能正常工作

**下一步（可选）：**

1. 在生产环境测试 S3 存储配置
2. 将现有 ActiveStorage 文件迁移到 S3（如需要）
3. 优先使用 logo_url 字段存储图标 URL
