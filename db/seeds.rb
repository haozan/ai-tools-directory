# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'yaml'

puts "Seeding database..."

# ============================================================
# Import Categories and Tools from YAML
# ============================================================
file_path = Rails.root.join('db', 'data', 'tools.yml')

if File.exist?(file_path)
  puts "\n📂 Loading data from #{file_path}..."
  data = YAML.load_file(file_path)
  
  # Import Categories (with parent support)
  if data['categories']
    puts "\n📁 Processing categories..."
    
    # First pass: Create all root categories (no parent)
    root_categories = data['categories'].select { |cat| cat['parent'].blank? }
    root_categories.each do |cat_data|
      category = Category.find_or_initialize_by(name: cat_data['name'], parent_id: nil)
      category.description = cat_data['description']
      category.position = cat_data['position'] if cat_data['position'].present?
      
      if category.save
        puts "  ✅ #{category.new_record? ? 'Created' : 'Updated'} root category: #{category.name}"
      else
        puts "  ❌ Failed to save category: #{category.name} - #{category.errors.full_messages.join(', ')}"
      end
    end
    
    # Second pass: Create child categories (with parent)
    child_categories = data['categories'].select { |cat| cat['parent'].present? }
    child_categories.each do |cat_data|
      parent = Category.find_by(name: cat_data['parent'])
      
      unless parent
        puts "  ⚠️  Skipping: Parent category '#{cat_data['parent']}' not found"
        next
      end
      
      category = Category.find_or_initialize_by(name: cat_data['name'], parent_id: parent.id)
      category.description = cat_data['description']
      category.position = cat_data['position'] if cat_data['position'].present?
      
      if category.save
        puts "  ✅ #{category.new_record? ? 'Created' : 'Updated'} child category: #{category.name} (parent: #{parent.name})"
      else
        puts "  ❌ Failed to save category: #{category.name} - #{category.errors.full_messages.join(', ')}"
      end
    end
  end
  
  # Import Tools
  if data['tools']
    puts "\n🔧 Processing tools..."
    success_count = 0
    skip_count = 0
    error_count = 0
    
    data['tools'].each do |tool_data|
      begin
        tool = Tool.find_or_initialize_by(name: tool_data['name'])
        
        # Skip if no changes
        if !tool.new_record? && 
           tool.website_url == tool_data['website_url'] && 
           tool.short_description == tool_data['short_description']
          skip_count += 1
          next
        end
        
        # Update attributes (skip pricing_type if not present)
        tool.website_url = tool_data['website_url']
        tool.short_description = tool_data['short_description']
        tool.long_description = tool_data['long_description'] if tool_data['long_description'].present?
        tool.logo_url = tool_data['logo_url'] if tool_data['logo_url'].present?
        tool.featured = tool_data['featured'] if tool_data.key?('featured')
        
        if tool.save
          # Associate categories
          if tool_data['categories'].present?
            category_names = tool_data['categories']
            categories = Category.where(name: category_names)
            
            if categories.count != category_names.count
              missing = category_names - categories.pluck(:name)
              puts "  ⚠️  Warning: Missing categories for #{tool.name}: #{missing.join(', ')}"
            end
            
            tool.categories = categories
          end
          
          success_count += 1
        else
          puts "  ❌ Failed to save tool: #{tool.name} - #{tool.errors.full_messages.join(', ')}"
          error_count += 1
        end
      rescue StandardError => e
        puts "  ❌ Error processing #{tool_data['name']}: #{e.message}"
        error_count += 1
      end
    end
    
    puts "\n" + "="*60
    puts "📊 Import Summary:"
    puts "  ✅ Created/Updated: #{success_count}"
    puts "  ⏭️  Skipped: #{skip_count}"
    puts "  ❌ Failed: #{error_count}"
    puts "  📦 Total: #{data['tools'].count}"
    puts "="*60
  end
  
  # Update category tools count
  puts "\n🔄 Updating category tools count..."
  Category.find_each(&:update_tools_count!)
  puts "✅ Category counts updated"
else
  puts "⚠️  Warning: #{file_path} not found. Skipping tools import."
end

# ============================================================
# Create Resources (Learning materials)
# ============================================================
puts "\n📚 Creating resources..."

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
    description: "In-depth conversations with leading experts in AI, robotics, and technology. Features researchers, entrepreneurs, and thought leaders.",
    url: "https://youtube.com/@lexfridman",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1478737270239-2f02b77fc618?w=400&auto=format&fit=crop",
    subscribers_count: "3.5M",
    view_count: 120345
  },
  {
    title: "Yannic Kilcher",
    description: "Deep dives into AI research papers, explaining complex concepts in machine learning and neural networks.",
    url: "https://youtube.com/@YannicKilcher",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=400&auto=format&fit=crop",
    subscribers_count: "320K",
    view_count: 45678
  },
  {
    title: "AI Explained",
    description: "Clear explanations of AI concepts, latest research, and practical applications for beginners and enthusiasts.",
    url: "https://youtube.com/@ai-explained-",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1535378917042-10a22c95931a?w=400&auto=format&fit=crop",
    subscribers_count: "250K",
    view_count: 34567
  },
  {
    title: "Sam Witteveen",
    description: "Practical AI tutorials focusing on LangChain, prompt engineering, and building AI applications.",
    url: "https://youtube.com/@samwitteveenai",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=400&auto=format&fit=crop",
    subscribers_count: "180K",
    view_count: 23456
  },
  {
    title: "Matt Wolfe",
    description: "Weekly updates on the latest AI tools, news, and practical applications for creators and entrepreneurs.",
    url: "https://youtube.com/@mreflow",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400&auto=format&fit=crop",
    subscribers_count: "420K",
    view_count: 56789
  },
  {
    title: "The AI Advantage",
    description: "Productivity tips and tutorials for using AI tools like ChatGPT, Claude, and automation tools effectively.",
    url: "https://youtube.com/@aiadvantage",
    category: "media",
    logo_url: "https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?w=400&auto=format&fit=crop",
    subscribers_count: "280K",
    view_count: 45678
  }
]

resources_data.each do |resource_data|
  resource = Resource.find_or_create_by!(title: resource_data[:title]) do |r|
    r.assign_attributes(resource_data)
  end
  puts "  Created: #{resource.title}"
end

puts "Created #{Resource.count} resources"
puts "  - #{Resource.where(category: 'video').count} video tutorials"
puts "  - #{Resource.where(category: 'document').count} documents"
puts "  - #{Resource.where(category: 'media').count} media creators"

# ============================================================
# Create Default Administrator
# ============================================================
if Administrator.count.zero?
  admin = Administrator.create!(
    name: 'admin',
    role: 'super_admin',
    password: 'password123',
    password_confirmation: 'password123'
  )
  puts "\n✅ Created default admin: #{admin.name} (password: password123)"
end

# ============================================================
# Final Summary
# ============================================================
puts "\n✅ Seeding completed!"
puts "📊 Summary:"
puts "  - #{Category.count} categories"
puts "  - #{Category.root_categories.count} root categories"
puts "  - #{Category.child_categories.count} child categories"
puts "  - #{Tool.count} tools"
puts "  - #{Resource.count} resources"
puts "  - #{Administrator.count} administrators"
