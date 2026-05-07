FactoryBot.define do
  factory :transaction do
    association :account
    amount { 100.00 }
    transaction_type { "deposit" }
  end
end
