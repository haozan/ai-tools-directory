# 生产环境同步指南

## 问题说明

目前存在两个主要问题：

1. **分类结构不一致**：开发环境已删除 AI 大模型分类并重组结构，但生产环境还是旧的结构
2. **图标丢失**：生产环境的工具图标无法显示

## 解决方案

### 1. 同步分类结构到生产环境

#### 方法一：直接在生产环境运行 seed（推荐）

```bash
# 1. 确保 db/data/tools.yml 已经提交到 Git
git add db/data/tools.yml
git commit -m "Update category structure"
git push

# 2. 在生产环境拉取最新代码
git pull

# 3. 在生产环境运行 seed
RAILS_ENV=production rails db:seed
```

#### 方法二：在生产环境直接更新数据库

```bash
# 1. 删除 AI 大模型 分类
RAILS_ENV=production rails runner "
  ai_model = Category.find_by(name: 'AI 大模型')
  ai_model.destroy if ai_model
"

# 2. 将子分类移动到通用大模型
RAILS_ENV=production rails runner "
  general = Category.find_by(name: '通用大模型')
  ['API 聚合', '国内通用大模型', '国外通用大模型', '法律大模型'].each do |name|
    cat = Category.find_by(name: name)
    cat.update(parent_id: general.id) if cat
  end
"

# 3. 设置龙虾频道为一级分类并放在第一位
RAILS_ENV=production rails runner "
  lobster = Category.find_by(name: '龙虾频道')
  lobster.update(parent_id: nil, position: 0) if lobster
"
```

### 2. 解决图标丢失问题

#### 问题原因

- 工具的图标使用 ActiveStorage 存储
- ActiveStorage 默认使用本地磁盘存储（`storage/` 目录）
- 生产环境没有开发环境的 `storage/` 文件夹内容，所以图标无法显示

#### 解决方案A：使用 AWS S3（推荐）

1. **安装 AWS SDK gem**（已在 Gemfile 中）：
```ruby
gem "aws-sdk-s3", require: false
```

2. **配置 S3**：

编辑 `config/storage.yml`：
```yaml
amazon:
  service: S3
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
  region: <%= ENV['AWS_REGION'] || 'us-east-1' %>
  bucket: <%= ENV['AWS_S3_BUCKET'] %>
```

3. **设置环境变量**：

在 `config/application.yml` 添加：
```yaml
production:
  AWS_ACCESS_KEY_ID: "your_access_key"
  AWS_SECRET_ACCESS_KEY: "your_secret_key"
  AWS_REGION: "us-east-1"
  AWS_S3_BUCKET: "your-bucket-name"
```

4. **修改生产环境配置**：

编辑 `config/environments/production.rb`：
```ruby
# 改为使用 S3
config.active_storage.service = :amazon
```

5. **迁移现有文件到 S3**：
```bash
# 在开发环境导出所有图标 URL
rails runner "Tool.where.not(logo_url: nil).each { |t| puts t.id.to_s + ',' + t.logo_url }"

# 或者编写迁移脚本上传 storage/ 文件到 S3
```

#### 解决方案B：使用共享文件系统

如果使用 NFS 或共享卷，将 `storage/` 目录挂载到生产环境。

#### 解决方案C：只使用外部 URL（最简单）

1. 确保所有工具都使用 `logo_url` 字段（外部 URL，如 Unsplash）
2. 不使用 ActiveStorage 的 `logo` 附件

在 `db/data/tools.yml` 中确保所有工具都有 `logo_url`：
```yaml
- name: ClawHub
  website_url: https://clawhub.ai/
  short_description: AI 工具聚合平台
  logo_url: https://images.unsplash.com/photo-xxx  # 使用外部 URL
  featured: false
  categories:
  - 龙虾频道
```

### 3. 验证同步结果

```bash
# 检查生产环境分类结构
RAILS_ENV=production rails runner "
  puts '一级分类:'
  Category.where(parent_id: nil).order(:position, :id).each { |c| puts '  - ' + c.name }
  puts ''
  puts '通用大模型的二级分类:'
  general = Category.find_by(name: '通用大模型')
  general.children.each { |c| puts '  - ' + c.name } if general
"

# 检查工具数量
RAILS_ENV=production rails runner "
  puts 'Total categories: ' + Category.count.to_s
  puts 'Total tools: ' + Tool.count.to_s
"
```

## 推荐方案

**短期解决方案**（立即可用）：
1. 运行 `RAILS_ENV=production rails db:seed` 同步分类结构
2. 对于图标，暂时让没有 logo_url 的工具使用默认图标

**长期解决方案**（稳定可靠）：
1. 配置 ActiveStorage 使用 AWS S3
2. 将所有 ActiveStorage 文件迁移到 S3
3. 以后新上传的图标都自动存储到 S3

## 常见问题

### Q: 为什么不直接复制 storage/ 目录到生产环境？

A: 因为：
- 每次部署都需要手动复制，容易遗漏
- 多服务器环境下无法共享文件
- 容器化部署（如 Docker）每次重启会丢失文件

### Q: 使用 S3 会增加成本吗？

A: 
- S3 成本很低（每GB约 $0.023/月）
- 对于图标文件，预计每月只需几美元
- 可以使用 CloudFlare R2（兼容 S3 API，流量免费）

### Q: 如何迁移现有的 ActiveStorage 文件？

A: 
```ruby
# 将本地文件上传到 S3
Tool.where.not(logo: { attached: nil }).each do |tool|
  next unless tool.logo.attached?
  
  # 下载文件内容
  file_content = tool.logo.download
  
  # 重新上传到 S3（确保 production 环境已配置 S3）
  tool.logo.attach(
    io: StringIO.new(file_content),
    filename: tool.logo.filename.to_s,
    content_type: tool.logo.content_type
  )
end
```

## 部署清单

- [ ] 提交 `db/data/tools.yml` 到 Git
- [ ] 拉取最新代码到生产环境
- [ ] 运行 `RAILS_ENV=production rails db:seed`
- [ ] 验证分类结构正确
- [ ] 配置 S3（如需要）
- [ ] 迁移图标文件到 S3（如需要）
- [ ] 测试生产环境页面显示正常
