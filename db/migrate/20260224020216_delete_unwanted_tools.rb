class DeleteUnwantedTools < ActiveRecord::Migration[7.2]
  def up
    # Delete tools by name (safer than by ID in case IDs differ between environments)
    tool_names_to_delete = [
      'Jasper AI',
      'Copy.ai',
      'GitHub Copilot',
      'Stable Diffusion',
      'Synthesia',
      'Grammarly',
      'Notion AI',
      'Eleven Labs',
      'GitHub Copilot Test',
      'Runway ML',
      'AI工具集导航',
      '金助理',
      '智能判决预测',
      '法律咨询AI',
      '印象笔记',
      '百度文库',
      '沉浸式翻译'
    ]
    
    # Find tools by name and delete them
    tools_to_delete = Tool.where(name: tool_names_to_delete)
    
    say "Deleting #{tools_to_delete.count} tools..."
    tools_to_delete.each do |tool|
      say "  - #{tool.name} (ID: #{tool.id})"
    end
    
    # Delete tool_categories associations first (handled by dependent: :destroy)
    tools_to_delete.destroy_all
    
    say "✅ Successfully deleted #{tool_names_to_delete.count} tools"
  end
  
  def down
    # Cannot rollback deleted data
    raise ActiveRecord::IrreversibleMigration, "Cannot restore deleted tools"
  end
end
