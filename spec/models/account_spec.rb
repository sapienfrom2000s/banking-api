require "rails_helper"

RSpec.describe Account, type: :model do
  describe "associations" do
    it "belongs to a user" do
      account = create(:account)
      expect(account.user).to be_a(User)
    end

    it "has many transactions" do
      account = create(:account)
      create(:transaction, account: account)
      create(:transaction, account: account)
      expect(account.transactions.count).to eq(2)
    end

    it "destroys associated transactions when account is deleted" do
      account = create(:account)
      create(:transaction, account: account)
      expect { account.destroy }.to change(Transaction, :count).by(-1)
    end
  end

  describe "validations" do
    it "is valid with a non-negative balance" do
      expect(build(:account, balance: 0)).to be_valid
    end

    it "is invalid with a negative balance" do
      expect(build(:account, balance: -1)).not_to be_valid
    end
  end
end
