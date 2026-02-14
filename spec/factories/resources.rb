FactoryBot.define do
  factory :resource do

    title { "MyString" }
    description { "MyText" }
    url { "MyString" }
    category { "MyString" }
    subscribers_count { "MyString" }
    logo_url { "MyString" }
    featured { true }
    view_count { 1 }

  end
end
