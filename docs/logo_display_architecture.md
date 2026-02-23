# 工具图标显示架构说明

## 概述

本项目使用统一的 `logo_image_url` 方法来处理工具图标的显示,支持两种存储方式:
1. **ActiveStorage 附件** (优先)
2. **外部 URL** (`logo_url` 字段)

## 核心方法

### `Tool#logo_image_url`

定义位置: `app/models/tool.rb`

```ruby
def logo_image_url
  if logo.attached?
    Rails.application.routes.url_helpers.rails_blob_url(logo, only_path: true)
  else
    logo_url.presence
  end
end
```

**工作原理:**
1. 首先检查是否有 ActiveStorage 附件 (`logo.attached?`)
2. 如果有附件,返回 ActiveStorage blob URL (如 `/rails/active_storage/blobs/redirect/...`)
3. 如果没有附件,使用 `logo_url` 字段(外部 URL,如 Unsplash)

## 视图文件使用规范

### ✅ 正确用法

**所有前端视图必须使用 `logo_image_url`:**

```erb
<% if tool.logo_image_url.present? %>
  <img src="<%= tool.logo_image_url %>" alt="<%= tool.name %>" 
       class="w-full h-full object-cover" 
       loading="lazy" decoding="async" />
<% else %>
  <!-- 显示默认图标 -->
  <div class="w-full h-full flex items-center justify-center gradient-primary">
    <%= lucide_icon "sparkles", class: "w-12 h-12 text-surface-elevated" %>
  </div>
<% end %>
```

**已正确实现的视图:**
- ✅ `app/views/home/index.html.erb` (第78-79行)
- ✅ `app/views/tools/index.html.erb` (第56-57行)
- ✅ `app/views/tools/show.html.erb` (第22-23、115-116行)
- ✅ `app/views/categories/show.html.erb` (第83-84行)
- ✅ `app/views/categories/_tools_grid.html.erb` (第8-9行)

### ❌ 错误用法

**不要直接使用 `tool.logo_url`:**

```erb
<!-- ❌ 错误 - 会跳过 ActiveStorage 附件 -->
<% if tool.logo_url.present? %>
  <img src="<%= tool.logo_url %>" alt="<%= tool.name %>" />
<% end %>
```

**为什么错误:**
- 直接使用 `logo_url` 会忽略 ActiveStorage 附件
- 导致有附件的工具在生产环境中无法显示图标
- 不同路由可能显示不一致的结果

## 数据存储

### 开发环境
- ActiveStorage 附件存储在本地文件系统 (`storage/`)
- `logo_url` 字段通常指向外部 URL (Unsplash)

### 生产环境
- 配置: `config.active_storage.service = :local` (存储在服务器本地)
- ActiveStorage 附件存储在 `/home/runner/app/storage/`
- 通过 `/rails/active_storage/blobs/redirect/` 路由访问

## 数据同步

### YAML 配置 (`db/data/tools.yml`)

```yaml
- name: ClawHub
  website_url: https://clawhub.example.com
  short_description: 龙虾工具平台
  logo_url: https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400
  categories:
    - 龙虾频道
```

### 同步流程

1. 运行 `DataSyncService.call` 或 `rails db:seed`
2. 如果 YAML 中有 `logo_url`,系统会:
   - 从 URL 下载图片
   - 创建 ActiveStorage 附件
   - 同时保存 `logo_url` 字段(作为备份)

## 管理后台

### Admin 视图

管理后台可以直接使用 `logo_url` 字段进行编辑和显示:

```erb
<!-- Admin 表单 -->
<%= form.text_field :logo_url, placeholder: "留空则自动从网站提取 OG 图..." %>

<!-- Admin 显示 -->
<% if @tool.logo_url.present? %>
  <%= image_tag @tool.logo_url, class: "w-24 h-24 object-cover rounded-lg" rescue nil %>
<% end %>
```

**原因:** 管理后台需要直接查看和编辑 `logo_url` 字段,不需要通过 `logo_image_url` 方法。

## 测试验证

### 检查图标显示

```bash
# 在 Rails console 中检查
rails runner "
  tool = Tool.find_by(name: 'ClawHub')
  puts 'logo.attached? ' + tool.logo.attached?.to_s
  puts 'logo_url: ' + tool.logo_url.to_s
  puts 'logo_image_url: ' + tool.logo_image_url.to_s
"
```

### 运行测试

```bash
# 分类页面测试
bundle exec rspec spec/requests/categories_spec.rb

# 工具页面测试
bundle exec rspec spec/requests/tools_spec.rb

# 完整测试套件
rake test
```

## 故障排查

### 问题: 图标在某些页面显示,某些页面不显示

**原因:** 视图文件使用了 `tool.logo_url` 而不是 `tool.logo_image_url`

**解决方案:**
1. 搜索视图文件: `grep -rn 'tool\.logo_url' app/views/ --include='*.erb'`
2. 将所有 `tool.logo_url` 替换为 `tool.logo_image_url`
3. 确保检查条件也改为: `<% if tool.logo_image_url.present? %>`

### 问题: 生产环境中图标缺失

**检查清单:**
1. ✅ 确认 `config.active_storage.service = :local` (production.rb)
2. ✅ 确认视图使用 `logo_image_url` 而不是 `logo_url`
3. ✅ 确认资产预编译配置正确 (`config/initializers/assets.rb`)
4. ✅ 确认 `app/assets/config/manifest.js` 存在

### 问题: 从 YAML 同步后图标仍然缺失

**解决方案:**
1. 检查 YAML 中的 `logo_url` 是否可访问
2. 运行 `DataSyncService.call` 重新同步
3. 检查日志中是否有下载失败的错误

## 最佳实践

1. **前端视图:** 始终使用 `tool.logo_image_url`
2. **YAML 配置:** 使用可靠的外部 URL (推荐 Unsplash)
3. **性能优化:** 添加 `loading="lazy"` 和 `decoding="async"` 属性
4. **测试覆盖:** 在测试中验证图标显示逻辑
5. **错误处理:** 提供默认图标作为后备方案

## 相关文件

- 模型: `app/models/tool.rb`
- 视图: `app/views/{home,tools,categories}/*.html.erb`
- 配置: `config/environments/production.rb`
- 数据: `db/data/tools.yml`
- 服务: `app/services/data_sync_service.rb`
