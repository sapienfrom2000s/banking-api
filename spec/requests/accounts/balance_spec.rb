require "rails_helper"

RSpec.describe "GET /accounts/:id/balance", type: :request do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:token) { JwtService.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  context "when unauthenticated" do
    it "returns 401 when Authorization header is missing" do
      get "/accounts/#{account.id}/balance"
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    end

    it "returns 401 when token is invalid" do
      get "/accounts/#{account.id}/balance", headers: { "Authorization" => "Bearer invalidtoken" }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    end

    it "returns 401 when token is expired" do
      expired_token = JwtService.encode({ user_id: user.id, exp: 1.hour.ago.to_i })
      get "/accounts/#{account.id}/balance", headers: { "Authorization" => "Bearer #{expired_token}" }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    end
  end

  context "when authenticated" do
    it "returns 200 with the account balance" do
      get "/accounts/#{account.id}/balance", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("balance" => account.balance.to_s)
    end

    it "returns 404 when account is not found" do
      get "/accounts/99999/balance", headers: headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to include("error" => "Account not found")
    end

    it "returns 403 when account belongs to another user" do
      other_account = create(:account)
      get "/accounts/#{other_account.id}/balance", headers: headers
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)).to include("error" => "Forbidden")
    end
  end
end
