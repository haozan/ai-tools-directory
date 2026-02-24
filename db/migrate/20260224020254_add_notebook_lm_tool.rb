class AddNotebookLmTool < ActiveRecord::Migration[7.2]
  def up
    # Find the "国外大模型" category
    category = Category.find_by(name: '国外大模型')
    
    unless category
      say "⚠️  Category '国外大模型' not found, skipping..."
      return
    end
    
    # Check if NotebookLM already exists
    existing_tool = Tool.find_by(name: 'NotebookLM')
    if existing_tool
      say "ℹ️  NotebookLM already exists (ID: #{existing_tool.id}), skipping..."
      return
    end
    
    # Create NotebookLM tool
    tool = Tool.create!(
      name: 'NotebookLM',
      short_description: 'Google推出的AI驱动笔记和研究助手',
      long_description: 'NotebookLM是Google推出的AI驱动笔记和研究助手，能够理解和总结文档内容，帮助用户进行研究和学习。它可以从上传的文档中提取关键信息，生成摘要，并回答相关问题。',
      website_url: 'https://notebooklm.google.com/',
      featured: false
    )
    
    # Associate with category
    ToolCategory.create!(tool_id: tool.id, category_id: category.id)
    
    say "✅ Successfully created NotebookLM (ID: #{tool.id})"
  end
  
  def down
    tool = Tool.find_by(name: 'NotebookLM')
    if tool
      tool.destroy
      say "✅ Deleted NotebookLM"
    end
  end
end
