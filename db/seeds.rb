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
    pricing_type: "Freemium",
    categories: ["Text & Writing", "Productivity"]
  },
  {
    name: "Midjourney",
    website_url: "https://midjourney.com",
    short_description: "AI art generator creating stunning images from text descriptions",
    long_description: "Midjourney is a powerful AI art generator that creates high-quality, imaginative images from text prompts. Perfect for artists, designers, and creative professionals.",
    logo_url: "https://images.unsplash.com/photo-1686191128892-c0f18d9f5fcd?w=400&auto=format&fit=crop",
    pricing_type: "Paid",
    categories: ["Image Generation"]
  },
  {
    name: "Eleven Labs",
    website_url: "https://elevenlabs.io",
    short_description: "Realistic AI voice generation and voice cloning technology",
    long_description: "Eleven Labs offers cutting-edge text-to-speech and voice cloning technology with incredibly realistic results. Ideal for content creators and developers.",
    logo_url: "https://images.unsplash.com/photo-1589903308904-1010c2294adc?w=400&auto=format&fit=crop",
    pricing_type: "Freemium",
    categories: ["Audio & Voice"]
  },
  {
    name: "Runway ML",
    website_url: "https://runwayml.com",
    short_description: "Professional AI video editing and generation platform",
    long_description: "Runway ML provides advanced AI tools for video editing, generation, and effects. Used by creative professionals worldwide for cutting-edge video production.",
    logo_url: "https://images.unsplash.com/photo-1492619375914-88005aa9e8fb?w=400&auto=format&fit=crop",
    pricing_type: "Freemium",
    categories: ["Video Creation"]
  },
  {
    name: "GitHub Copilot",
    website_url: "https://github.com/features/copilot",
    short_description: "AI pair programmer helping developers write code faster",
    long_description: "GitHub Copilot is an AI-powered code completion tool that suggests entire lines or blocks of code as you type, trained on billions of lines of code.",
    logo_url: "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400&auto=format&fit=crop",
    pricing_type: "Paid",
    categories: ["Code Assistant", "Productivity"]
  },
  {
    name: "Jasper AI",
    website_url: "https://jasper.ai",
    short_description: "AI content writer for marketing and blog content",
    long_description: "Jasper AI helps marketers and content creators produce high-quality content faster. From blog posts to ad copy, Jasper streamlines the writing process.",
    logo_url: "https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400&auto=format&fit=crop",
    pricing_type: "Paid",
    categories: ["Text & Writing", "Marketing"]
  },
  {
    name: "DALL-E 3",
    website_url: "https://openai.com/dall-e-3",
    short_description: "Advanced text-to-image generation by OpenAI",
    long_description: "DALL-E 3 is OpenAI's latest image generation model, creating highly detailed and accurate images from text descriptions with improved understanding.",
    logo_url: "https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400&auto=format&fit=crop",
    pricing_type: "Freemium",
    categories: ["Image Generation"]
  },
  {
    name: "Copy.ai",
    website_url: "https://copy.ai",
    short_description: "AI writing assistant for various content types",
    long_description: "Copy.ai is an AI-powered writing tool that helps create marketing copy, product descriptions, social media posts, and more in seconds.",
    logo_url: "https://images.unsplash.com/photo-1542435503-956c469947f6?w=400&auto=format&fit=crop",
    pricing_type: "Freemium",
    categories: ["Text & Writing", "Marketing"]
  },
  {
    name: "Notion AI",
    website_url: "https://notion.so/product/ai",
    short_description: "AI-powered writing and organization within Notion",
    long_description: "Notion AI integrates directly into your Notion workspace, helping you write, brainstorm, and organize information more efficiently.",
    logo_url: "https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&auto=format&fit=crop",
    pricing_type: "Freemium",
    categories: ["Text & Writing", "Productivity"]
  },
  {
    name: "Stable Diffusion",
    website_url: "https://stability.ai",
    short_description: "Open-source AI image generation model",
    long_description: "Stable Diffusion is a powerful open-source text-to-image model that can generate detailed images from text descriptions, available for free use.",
    logo_url: "https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?w=400&auto=format&fit=crop",
    pricing_type: "Free",
    categories: ["Image Generation"]
  },
  {
    name: "Synthesia",
    website_url: "https://synthesia.io",
    short_description: "Create AI videos with virtual avatars",
    long_description: "Synthesia enables you to create professional videos with AI avatars speaking your script in multiple languages, without cameras or actors.",
    logo_url: "https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=400&auto=format&fit=crop",
    pricing_type: "Paid",
    categories: ["Video Creation", "Marketing"]
  },
  {
    name: "Grammarly",
    website_url: "https://grammarly.com",
    short_description: "AI-powered writing assistant and grammar checker",
    long_description: "Grammarly uses AI to improve your writing by checking grammar, spelling, style, and tone across all your applications and websites.",
    logo_url: "https://images.unsplash.com/photo-1456324504439-367cee3b3c32?w=400&auto=format&fit=crop",
    pricing_type: "Freemium",
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
