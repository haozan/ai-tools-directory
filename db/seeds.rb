# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create Categories
categories_data = [
  { name: "Text & Writing", description: "AI tools for text generation, writing assistance, and content creation" },
  { name: "Image Generation", description: "Create stunning images and artwork using AI" },
  { name: "Audio & Voice", description: "AI-powered voice synthesis, music generation, and audio processing" },
  { name: "Video Creation", description: "Generate and edit videos with artificial intelligence" },
  { name: "3D & Design", description: "3D modeling, design tools powered by AI" },
  { name: "Code Assistant", description: "AI tools to help developers write better code faster" },
  { name: "Productivity", description: "Boost your productivity with AI-powered tools" },
  { name: "Marketing", description: "AI tools for marketing, advertising, and growth" }
]

puts "Creating categories..."
categories = categories_data.map do |cat_data|
  Category.find_or_create_by!(name: cat_data[:name]) do |cat|
    cat.description = cat_data[:description]
  end
end
puts "Created #{categories.count} categories"

# Create Tools
tools_data = [
  {
    name: "ChatGPT",
    website_url: "https://chat.openai.com",
    short_description: "Conversational AI assistant for text generation and problem-solving",
    long_description: "ChatGPT is a state-of-the-art conversational AI developed by OpenAI. It can assist with writing, coding, analysis, and creative tasks through natural dialogue.",
    logo_url: "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&auto=format&fit=crop",
    categories: ["Text & Writing", "Productivity"]
  },
  {
    name: "Midjourney",
    website_url: "https://midjourney.com",
    short_description: "AI art generator creating stunning images from text descriptions",
    long_description: "Midjourney is a powerful AI art generator that creates high-quality, imaginative images from text prompts. Perfect for artists, designers, and creative professionals.",
    logo_url: "https://images.unsplash.com/photo-1686191128892-c0f18d9f5fcd?w=400&auto=format&fit=crop",
    categories: ["Image Generation"]
  },
  {
    name: "Eleven Labs",
    website_url: "https://elevenlabs.io",
    short_description: "Realistic AI voice generation and voice cloning technology",
    long_description: "Eleven Labs offers cutting-edge text-to-speech and voice cloning technology with incredibly realistic results. Ideal for content creators and developers.",
    logo_url: "https://images.unsplash.com/photo-1589903308904-1010c2294adc?w=400&auto=format&fit=crop",
    categories: ["Audio & Voice"]
  },
  {
    name: "Runway ML",
    website_url: "https://runwayml.com",
    short_description: "Professional AI video editing and generation platform",
    long_description: "Runway ML provides advanced AI tools for video editing, generation, and effects. Used by creative professionals worldwide for cutting-edge video production.",
    logo_url: "https://images.unsplash.com/photo-1492619375914-88005aa9e8fb?w=400&auto=format&fit=crop",
    categories: ["Video Creation"]
  },
  {
    name: "GitHub Copilot",
    website_url: "https://github.com/features/copilot",
    short_description: "AI pair programmer helping developers write code faster",
    long_description: "GitHub Copilot is an AI-powered code completion tool that suggests entire lines or blocks of code as you type, trained on billions of lines of code.",
    logo_url: "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400&auto=format&fit=crop",
    categories: ["Code Assistant", "Productivity"]
  },
  {
    name: "Jasper AI",
    website_url: "https://jasper.ai",
    short_description: "AI content writer for marketing and blog content",
    long_description: "Jasper AI helps marketers and content creators produce high-quality content faster. From blog posts to ad copy, Jasper streamlines the writing process.",
    logo_url: "https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400&auto=format&fit=crop",
    categories: ["Text & Writing", "Marketing"]
  },
  {
    name: "DALL-E 3",
    website_url: "https://openai.com/dall-e-3",
    short_description: "Advanced text-to-image generation by OpenAI",
    long_description: "DALL-E 3 is OpenAI's latest image generation model, creating highly detailed and accurate images from text descriptions with improved understanding.",
    logo_url: "https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400&auto=format&fit=crop",
    categories: ["Image Generation"]
  },
  {
    name: "Copy.ai",
    website_url: "https://copy.ai",
    short_description: "AI writing assistant for various content types",
    long_description: "Copy.ai is an AI-powered writing tool that helps create marketing copy, product descriptions, social media posts, and more in seconds.",
    logo_url: "https://images.unsplash.com/photo-1542435503-956c469947f6?w=400&auto=format&fit=crop",
    categories: ["Text & Writing", "Marketing"]
  },
  {
    name: "Notion AI",
    website_url: "https://notion.so/product/ai",
    short_description: "AI-powered writing and organization within Notion",
    long_description: "Notion AI integrates directly into your Notion workspace, helping you write, brainstorm, and organize information more efficiently.",
    logo_url: "https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&auto=format&fit=crop",
    categories: ["Text & Writing", "Productivity"]
  },
  {
    name: "Stable Diffusion",
    website_url: "https://stability.ai",
    short_description: "Open-source AI image generation model",
    long_description: "Stable Diffusion is a powerful open-source text-to-image model that can generate detailed images from text descriptions, available for free use.",
    logo_url: "https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?w=400&auto=format&fit=crop",
    categories: ["Image Generation"]
  },
  {
    name: "Synthesia",
    website_url: "https://synthesia.io",
    short_description: "Create AI videos with virtual avatars",
    long_description: "Synthesia enables you to create professional videos with AI avatars speaking your script in multiple languages, without cameras or actors.",
    logo_url: "https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=400&auto=format&fit=crop",
    categories: ["Video Creation", "Marketing"]
  },
  {
    name: "Grammarly",
    website_url: "https://grammarly.com",
    short_description: "AI-powered writing assistant and grammar checker",
    long_description: "Grammarly uses AI to improve your writing by checking grammar, spelling, style, and tone across all your applications and websites.",
    logo_url: "https://images.unsplash.com/photo-1456324504439-367cee3b3c32?w=400&auto=format&fit=crop",
    categories: ["Text & Writing", "Productivity"]
  }
]

puts "Creating tools..."
tools_data.each do |tool_data|
  categories_names = tool_data.delete(:categories)
  tool = Tool.find_or_create_by!(name: tool_data[:name]) do |t|
    t.assign_attributes(tool_data)
  end
  
  # Assign categories
  tool_categories = categories.select { |c| categories_names.include?(c.name) }
  tool.categories = tool_categories
  
  puts "  Created: #{tool.name}"
end

puts "Created #{Tool.count} tools"

# Update category tools_count
puts "Updating category counts..."
Category.find_each do |category|
  category.update_tools_count!
end

# Create default admin if not exists
if Administrator.count.zero?
  admin = Administrator.create!(
    name: 'admin',
    role: 'super_admin',
    password: 'password123',
    password_confirmation: 'password123'
  )
  puts "Created default admin: #{admin.name} (password: password123)"
end

puts "\n✅ Seeding completed!"
puts "📊 Summary:"
puts "  - #{Category.count} categories"
puts "  - #{Tool.count} tools"
puts "  - #{Administrator.count} administrators"

# Create Resources
resources_data = [
  # Video Tutorials
  {
    title: "AI Fundamentals for Beginners",
    description: "A comprehensive introduction to artificial intelligence concepts, machine learning basics, and practical applications.",
    url: "https://youtube.com/watch?v=example1",
    category: "video",
    logo_url: "https://images.unsplash.com/photo-1485846234645-a62644f84728?w=400&auto=format&fit=crop",
    view_count: 15234
  },
  {
    title: "Deep Learning with PyTorch",
    description: "Learn how to build neural networks from scratch using PyTorch framework. Covers CNNs, RNNs, and transformers.",
    url: "https://youtube.com/watch?v=example2",
    category: "video",
    logo_url: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&auto=format&fit=crop",
    view_count: 23456
  },
  {
    title: "Prompt Engineering Masterclass",
    description: "Master the art of writing effective prompts for ChatGPT, Claude, and other large language models.",
    url: "https://youtube.com/watch?v=example3",
    category: "video",
    logo_url: "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&auto=format&fit=crop",
    view_count: 34567
  },
  
  # Document Resources
  {
    title: "OpenAI API Documentation",
    description: "Official documentation for OpenAI's GPT models, DALL-E, Whisper, and other AI APIs with code examples.",
    url: "https://platform.openai.com/docs",
    category: "document",
    view_count: 45678
  },
  {
    title: "Hugging Face Transformers Guide",
    description: "Complete guide to using Hugging Face's transformers library for NLP tasks, model training, and deployment.",
    url: "https://huggingface.co/docs/transformers",
    category: "document",
    view_count: 23456
  },
  {
    title: "LangChain Handbook",
    description: "Comprehensive handbook for building LLM-powered applications using LangChain framework with Python examples.",
    url: "https://python.langchain.com/docs",
    category: "document",
    view_count: 34567
  },
  {
    title: "Stable Diffusion Guide",
    description: "In-depth guide to using Stable Diffusion for image generation, including parameter tuning and model fine-tuning.",
    url: "https://stability.ai/docs",
    category: "document",
    view_count: 28901
  },
  {
    title: "AI Ethics & Safety Guidelines",
    description: "Best practices and ethical considerations for developing and deploying AI systems responsibly.",
    url: "https://ethics.ai/guidelines",
    category: "document",
    view_count: 12345
  },
  
  # AI Media/Creators
  {
    title: "Andrej Karpathy",
    description: "Renowned AI expert, former Tesla AI Director and OpenAI founding member. Shares educational content about AI, deep learning, and programming.",
    url: "https://youtube.com/@AndrejKarpathy",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&auto=format&fit=crop",
    subscribers_count: "1.15M",
    view_count: 89012
  },
  {
    title: "Two Minute Papers",
    description: "Breaking down cutting-edge AI research papers into digestible 2-minute videos. Covers latest developments in machine learning and computer graphics.",
    url: "https://youtube.com/@TwoMinutePapers",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&auto=format&fit=crop",
    subscribers_count: "1.45M",
    view_count: 67890
  },
  {
    title: "Lex Fridman",
    description: "AI researcher at MIT hosting in-depth conversations with leading experts in AI, robotics, physics, and philosophy.",
    url: "https://youtube.com/@lexfridman",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop",
    subscribers_count: "3.2M",
    view_count: 123456
  },
  {
    title: "Yannic Kilcher",
    description: "Deep dives into AI research papers with clear explanations. Covers NLP, computer vision, reinforcement learning, and more.",
    url: "https://youtube.com/@YannicKilcher",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&auto=format&fit=crop",
    subscribers_count: "428K",
    view_count: 45678
  },
  {
    title: "AI Explained",
    description: "Simplified explanations of complex AI concepts and latest AI news. Perfect for staying updated on AI developments.",
    url: "https://youtube.com/@aiexplained-official",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1535223289827-42f1e9919769?w=400&auto=format&fit=crop",
    subscribers_count: "234K",
    view_count: 34567
  },
  {
    title: "Sam Witteveen",
    description: "Practical tutorials on building LLM applications, prompt engineering, and AI automation tools.",
    url: "https://youtube.com/@samwitteveenai",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&auto=format&fit=crop",
    subscribers_count: "156K",
    view_count: 28901
  },
  {
    title: "Matt Wolfe",
    description: "Weekly AI news roundup and reviews of the latest AI tools. Helps you stay ahead of AI trends and discover new tools.",
    url: "https://youtube.com/@mreflow",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&auto=format&fit=crop",
    subscribers_count: "687K",
    view_count: 56789
  },
  {
    title: "The AI Advantage",
    description: "Practical AI tutorials focused on productivity and automation. Learn how to use AI tools effectively in your workflow.",
    url: "https://youtube.com/@aiadvantage",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&auto=format&fit=crop",
    subscribers_count: "245K",
    view_count: 23456
  }
]

puts "\nCreating resources..."
resources_data.each do |resource_data|
  resource = Resource.find_or_create_by!(title: resource_data[:title]) do |r|
    r.assign_attributes(resource_data)
  end
  puts "  Created: #{resource.title}"
end

puts "Created #{Resource.count} resources"
puts "  - #{Resource.by_category('video').count} video tutorials"
puts "  - #{Resource.by_category('document').count} documents"
puts "  - #{Resource.by_category('media').count} media creators"

# Chinese Categories and Tools
puts "\nCreating Chinese categories and tools..."

# 通用大模型 (should already exist, find it)
general_model_cat = Category.find_or_create_by!(name: '通用大模型') do |cat|
  cat.description = '通用人工智能大模型'
end

# 法律新媒体 (top-level category)
legal_media_cat = Category.find_or_create_by!(name: '法律新媒体') do |cat|
  cat.description = '法律相关的新媒体工具和平台'
end

# 法律新媒体的子分类
legal_subcategories = [
  { name: '文本创作', description: 'AI辅助法律文本创作工具' },
  { name: '图像创作', description: 'AI辅助法律相关图像创作' },
  { name: '视频创作', description: 'AI辅助法律视频内容创作' },
  { name: '发布平台', description: '法律新媒体内容发布平台' }
]

legal_subcategories.each do |subcat_data|
  Category.find_or_create_by!(name: subcat_data[:name], parent_id: legal_media_cat.id) do |cat|
    cat.description = subcat_data[:description]
  end
  puts "  Created subcategory: #{subcat_data[:name]} under 法律新媒体"
end

# API 聚合 (under 通用大模型)
api_aggregation_cat = Category.find_or_create_by!(name: 'API 聚合', parent_id: general_model_cat.id) do |cat|
  cat.description = 'AI模型API聚合服务平台'
end
puts "  Created: API 聚合 under 通用大模型"

# 阿里云百炼工具
bailian_tool = Tool.find_or_create_by!(name: '阿里云百炼') do |tool|
  tool.website_url = 'https://bailian.console.aliyun.com/'
  tool.short_description = '阿里云企业级AI应用开发平台，提供大模型服务、模型训练、应用构建等功能'
  tool.long_description = '阿里云百炼是阿里云推出的企业级AI应用开发平台，整合了通义大模型能力，为企业提供模型服务、模型训练、知识库管理、应用构建等一站式AI开发工具。支持多种大模型接入，提供丰富的API接口和SDK，帮助企业快速构建智能应用。'
end

# 将阿里云百炼添加到API聚合分类
unless bailian_tool.categories.include?(api_aggregation_cat)
  bailian_tool.categories << api_aggregation_cat
end

# 下载并附加阿里云百炼logo（如果还没有）
if !bailian_tool.logo.attached? && File.exist?('tmp/bailian_logo.png')
  bailian_tool.logo.attach(
    io: File.open('tmp/bailian_logo.png'),
    filename: 'bailian-logo.png',
    content_type: 'image/png'
  )
  puts "  Attached logo for 阿里云百炼"
end

puts "  Created tool: 阿里云百炼"

# Grok工具（如果存在则更新logo）
grok_tool = Tool.find_by(name: 'Grok')
if grok_tool
  # 下载并附加Grok logo（如果还没有）
  if !grok_tool.logo.attached? && File.exist?('tmp/grok_logo.webp')
    grok_tool.logo.attach(
      io: File.open('tmp/grok_logo.webp'),
      filename: 'grok-logo.webp',
      content_type: 'image/webp'
    )
    puts "  Attached logo for Grok"
  end
end

# 更新所有分类的工具计数
puts "\nUpdating all category counts..."
Category.find_each do |category|
  category.update_tools_count!
end

puts "\n✅ Chinese categories and tools seeding completed!"
