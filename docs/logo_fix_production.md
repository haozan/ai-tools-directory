# 生产环境 Logo 图标显示修复方案

## 问题描述

在测试环境通过 ActiveStorage 上传的工具图标，部署到生产环境后会消失。这是因为：

1. **测试环境**：图标存储在 ActiveStorage 本地文件系统
2. **生产环境**：本地文件不会随代码部署迁移，导致图标丢失
3. **DeepSeek 正常显示**：因为它的 `logo_url` 字段存储的是外部 S3 URL，不依赖本地存储

## 解决方案

将所有 logo 图片作为**静态资源**存储在代码仓库中，随代码一起部署。

### 实施步骤

#### 1. 导出 ActiveStorage 图片到静态资源目录

```bash
cd /home/runner/app
rails runner tmp/batch_export_logos.rb
```

这会将所有 ActiveStorage 附件导出到 `tmp/logos/` 目录。

#### 2. 移动图片到 public 目录

```bash
mkdir -p public/images/logos
cp tmp/logos/* public/images/logos/
```

共 34 个工具图标被复制到 `public/images/logos/` 目录。

#### 3. 更新 tools.yml 配置

```bash
rails runner tmp/update_tools_yml_with_static_logos.rb
```

这会自动更新 `db/data/tools.yml` 中所有工具的 `logo_url` 字段，指向静态资源路径：

```yaml
- name: Kimi
  logo_url: /images/logos/27_kimi_logo.webp  # 更新为静态路径
```

#### 4. 修改 Tool 模型逻辑

修改 `app/models/tool.rb` 中的 `logo_image_url` 方法，**优先使用 `logo_url` 字段**：

```ruby
def logo_image_url
  if logo_url.present?
    logo_url  # 优先使用静态资源路径
  elsif logo.attached?
    Rails.application.routes.url_helpers.rails_blob_url(logo, only_path: true)
  end
end
```

**修改原因**：
- 旧逻辑：优先 ActiveStorage → 生产环境找不到文件
- 新逻辑：优先 logo_url 字段 → 直接使用静态资源路径

## 受影响的工具列表（34个）

| 工具名称 | 静态资源路径 |
|---------|------------|
| MiniMax | `/images/logos/69_minimax_logo.png` |
| Kimi | `/images/logos/27_kimi_logo.webp` |
| 文心一言 | `/images/logos/28_wenxin.png` |
| 豆包 | `/images/logos/71_doubao_new.png` |
| 腾讯元宝 | `/images/logos/70_yuanbao_logo.png` |
| 讯飞星火 | `/images/logos/31_xinghuo_logo.png` |
| 通义千问 | `/images/logos/30_tongyi_qianwen_logo.png` |
| 智谱清言 | `/images/logos/29_zhipu_qingyan_logo.jpg` |
| 闪电说 | `/images/logos/14_shandianshuo_logo.png` |
| Claude | `/images/logos/36_claude.jpg` |
| Gemini | `/images/logos/35_gemini.jpg` |
| Grok | `/images/logos/72_grok-logo.webp` |
| OpenRouter | `/images/logos/66_openrouter_logo.png` |
| ... | ... |

完整列表见 `tmp/logos/` 目录。

## 部署到生产环境

### 步骤

1. **提交代码变更**
   ```bash
   git add public/images/logos
   git add db/data/tools.yml
   git add app/models/tool.rb
   git commit -m "Fix: 使用静态资源解决生产环境 logo 显示问题"
   git push
   ```

2. **部署到生产环境**
   - 生产环境会自动拉取最新代码
   - `public/images/logos` 目录中的图片会被包含在部署中
   - 数据同步服务会自动更新 `logo_url` 字段

3. **验证**
   ```bash
   # 在生产环境中验证
   curl -I https://your-domain.com/images/logos/27_kimi_logo.webp
   # 应该返回 200 OK
   ```

## 技术细节

### 为什么这种方案有效？

1. **静态资源随代码部署**
   - `public/images/logos` 中的图片会随 Git 仓库一起部署
   - 不依赖任何外部存储服务

2. **Rails 自动提供静态文件服务**
   - Rails 自动为 `public/` 目录提供静态文件服务
   - URL `/images/logos/xxx.png` 直接映射到 `public/images/logos/xxx.png`

3. **生产环境配置支持**
   ```ruby
   # config/environments/production.rb
   config.public_file_server.enabled = true
   config.public_file_server.headers = {
     'Cache-Control' => 'public, max-age=31536000, immutable'
   }
   ```

### 文件命名规则

静态资源文件使用 `{tool_id}_{original_filename}` 格式命名：
- 避免不同工具使用相同文件名冲突
- 便于通过 tool_id 快速定位文件
- 保留原始文件扩展名（png, jpg, webp等）

## 未来新工具的处理

对于未来新增的工具：

**方案 A：直接使用外部图床**
```yaml
- name: 新工具
  logo_url: https://images.unsplash.com/photo-xxx
```

**方案 B：上传到静态资源目录**
1. 在后台上传图片到 `public/images/logos/`
2. 更新 YAML 中的 `logo_url` 字段
3. 提交代码

**推荐方案 A**：使用外部图床（如 Unsplash、Cloudinary 或您的 S3），避免代码仓库体积膨胀。

## 测试结果

✅ 所有测试通过
✅ 34 个工具图标正确显示
✅ 静态资源路径可访问（HTTP 200）
✅ 页面正确使用静态资源路径

## 相关文件

- `public/images/logos/` - 静态图片目录（34个文件）
- `db/data/tools.yml` - 工具数据配置（logo_url 已更新）
- `app/models/tool.rb` - Tool 模型（logo_image_url 逻辑已修改）
- `tmp/batch_export_logos.rb` - 批量导出脚本
- `tmp/update_tools_yml_with_static_logos.rb` - 批量更新 YAML 脚本
