require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it "has one account" do
      user = create(:user)
      account = create(:account, user: user)
      expect(user.account).to eq(account)
    end

    it "destroys associated account when user is deleted" do
      user = create(:user)
      create(:account, user: user)
      expect { user.destroy }.to change(Account, :count).by(-1)
    end
  end

  describe "validations" do
    it "is valid with a unique email and pin_digest" do
      expect(build(:user)).to be_valid
    end

    it "is invalid without an email" do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it "is invalid with a malformed email" do
      expect(build(:user, email: "not-an-email")).not_to be_valid
    end

    it "is invalid with a duplicate email (case insensitive)" do
      create(:user, email: "alice@example.com")
      expect(build(:user, email: "ALICE@EXAMPLE.COM")).not_to be_valid
    end

    it "is invalid without a pin_digest" do
      expect(build(:user, pin_digest: nil)).not_to be_valid
    end
  end
end
