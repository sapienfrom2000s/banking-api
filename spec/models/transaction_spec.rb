require "rails_helper"

RSpec.describe Transaction, type: :model do
  describe "associations" do
    it "belongs to an account" do
      transaction = create(:transaction)
      expect(transaction.account).to be_a(Account)
    end
  end

  describe "validations" do
    it "is valid with a positive amount and transaction_type" do
      expect(build(:transaction)).to be_valid
    end

    it "is invalid with a zero amount" do
      expect(build(:transaction, amount: 0)).not_to be_valid
    end

    it "is invalid with a negative amount" do
      expect(build(:transaction, amount: -50)).not_to be_valid
    end

    it "is invalid without a transaction_type" do
      expect(build(:transaction, transaction_type: nil)).not_to be_valid
    end
  end
end
