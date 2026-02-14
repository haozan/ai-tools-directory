FactoryBot.define do
  factory :tool do
    sequence(:name) { |n| "Tool #{n}" }
    website_url { "https://example.com" }
    short_description { "A great AI tool" }
    long_description { "This is a comprehensive description of a great AI tool." }
    logo_url { "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&auto=format&fit=crop" }
    pricing_type { "Free" }
    view_count { 0 }
  end
end
