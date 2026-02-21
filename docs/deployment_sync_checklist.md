# 生产环境部署数据同步清单

## ✅ 部署前检查清单

### 1. 数据导出
- [ ] 在本地开发环境执行：`rails runner tmp/export_current_data.rb`
- [ ] 确认导出成功，检查输出信息：
  ```
  ✅ 数据已导出到: /path/to/db/data/kulawyer_tools.yml
  📊 统计信息:
    - 分类数量: XX
    - 工具数量: XX
  ```
- [ ] 验证 `db/data/kulawyer_tools.yml` 文件已更新

### 2. 代码提交
- [ ] 检查 Git 状态：`git status`
- [ ] 确认 `db/data/kulawyer_tools.yml` 在待提交列表中
- [ ] 提交更新：
  ```bash
  git add db/data/kulawyer_tools.yml
  git commit -m "Update tools database for production sync"
  git push
  ```

### 3. 部署到生产环境
- [ ] 确认代码已推送到远程仓库
- [ ] 执行生产环境部署流程
- [ ] 等待部署完成

## ✅ 部署后同步清单

### 1. 访问后台管理
- [ ] **备份生产数据库**（强烈建议）
- [ ] 打开生产环境后台地址：`https://your-domain.com/admin`
- [ ] 使用管理员账号登录
- [ ] 确认已进入 Dashboard 页面
- [ ] 阅读并理解完全同步模式：会删除不在 YAML 中的数据

### 2. 执行数据同步
- [ ] 在 "Quick Actions" 区域找到 **Sync Data** 按钮（紫色图标）
- [ ] 点击按钮，阅读确认对话框
- [ ] 确认同步操作
- [ ] 等待同步完成

### 3. 验证同步结果
- [ ] 检查页面顶部的同步结果消息
- [ ] 确认统计信息正确（新增/更新/删除的分类和工具数量）
- [ ] **如果有删除操作，验证已删除的数据确实不需要**
- [ ] 访问前台页面，验证数据显示正确
- [ ] 检查分类页面，确认分类和工具正确关联

## 📊 同步结果示例

**成功同步：**
```
数据同步成功！分类: 新增0个, 更新23个, 删除0个; 工具: 新增0个, 更新65个, 删除5个; 关联: 新增0个
```

**部分失败：**
```
数据同步成功！分类: 新增5个, 更新18个, 删除2个; 工具: 新增10个, 更新55个, 删除3个; 关联: 新增15个
部分数据同步失败: 分类 XXX: 错误信息; 工具 YYY: 错误信息
```

**完全失败：**
```
同步失败: 数据文件不存在: /path/to/db/data/kulawyer_tools.yml
```

## 🔧 故障排除

### 问题：数据文件不存在
**原因：** `db/data/kulawyer_tools.yml` 文件未提交或部署未包含此文件  
**解决方案：**
1. 确认本地文件存在
2. 检查 Git 状态，确保文件已提交
3. 重新部署应用

### 问题：YAML 格式错误
**原因：** 数据文件格式不正确  
**解决方案：**
1. 在本地重新运行导出脚本
2. 检查文件内容是否完整
3. 使用 YAML 验证工具检查格式

### 问题：部分数据同步失败
**原因：** 数据验证失败或数据库约束冲突  
**解决方案：**
1. 查看具体错误信息
2. 修复数据问题
3. 重新导出并部署

## 📝 注意事项

1. **完全同步模式**：同步操作会删除生产环境中不在 YAML 文件里的工具和分类，请确保 YAML 文件包含所有需要保留的数据
2. **事务保护**：同步操作在事务中执行，如果出现错误会自动回滚
3. **幂等性**：可以多次执行同步操作，但每次都会根据 YAML 删除多余数据
4. **备份建议**：首次同步前强烈建议备份生产数据库，以防意外删除

## 🎯 快速命令参考

```bash
# 1. 导出数据
rails runner tmp/export_current_data.rb

# 2. 提交代码
git add db/data/kulawyer_tools.yml
git commit -m "Update tools database for production sync"
git push

# 3. 部署（根据你的部署方式选择）
# Railway: 自动部署
# Heroku: git push heroku main
# 其他: 按照你的部署流程执行
```

## 📞 支持

如遇到问题，请查看：
- 数据同步详细文档：`docs/data_sync_guide.md`
- 工具管理指南：`docs/quick_start_tools.md`
- 分类管理指南：`docs/nested_categories_guide.md`
