FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    pin_digest { BCrypt::Password.create("1234") }

    trait :with_account do
      after(:create) { |user| create(:account, user: user) }
    end
  end
end
