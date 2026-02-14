FactoryBot.define do
  factory :administrator do
    sequence(:name) { |n| "admin#{n}" }
    password { "admin" }
    role { "admin" }
    
    trait :super_admin do
      role { "super_admin" }
    end
  end
end
