require "rails_helper"

RSpec.describe "POST /accounts/:id/deposit", type: :request do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user, balance: 1000.00) }
  let(:token) { JwtService.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  context "when unauthenticated" do
    it "returns 401 when Authorization header is missing" do
      post "/accounts/#{account.id}/deposit", params: { amount: 100 }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    end

    it "returns 401 when token is invalid" do
      post "/accounts/#{account.id}/deposit", params: { amount: 100 }, headers: { "Authorization" => "Bearer invalidtoken" }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    end

    it "returns 401 when token is expired" do
      expired_token = JwtService.encode({ user_id: user.id, exp: 1.hour.ago.to_i })
      post "/accounts/#{account.id}/deposit", params: { amount: 100 }, headers: { "Authorization" => "Bearer #{expired_token}" }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    end
  end

  context "when authenticated" do
    it "returns 200 with updated balance on valid deposit" do
      post "/accounts/#{account.id}/deposit", params: { amount: 100 }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        "message" => "Deposit successful",
        "balance" => "1100.0"
      )
    end

    it "returns 422 when amount is zero" do
      post "/accounts/#{account.id}/deposit", params: { amount: 0 }, headers: headers
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to include("error" => "Amount must be positive")
    end

    it "returns 422 when amount is negative" do
      post "/accounts/#{account.id}/deposit", params: { amount: -50 }, headers: headers
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to include("error" => "Amount must be positive")
    end

    it "returns 422 when amount is non-numeric" do
      post "/accounts/#{account.id}/deposit", params: { amount: "abc" }, headers: headers
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to include("error" => "Amount must be positive")
    end

    it "returns 422 when amount is missing" do
      post "/accounts/#{account.id}/deposit", headers: headers
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to include("error" => "Amount must be positive")
    end

    it "returns 404 when account is not found" do
      post "/accounts/99999/deposit", params: { amount: 100 }, headers: headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to include("error" => "Account not found")
    end

    it "returns 403 when account belongs to another user" do
      other_account = create(:account)
      post "/accounts/#{other_account.id}/deposit", params: { amount: 100 }, headers: headers
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)).to include("error" => "Forbidden")
    end
  end
end
