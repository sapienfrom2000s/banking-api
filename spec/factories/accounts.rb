FactoryBot.define do
  factory :account do
    association :user
    balance { 1000.00 }
  end
end
