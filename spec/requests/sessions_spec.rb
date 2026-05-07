require "rails_helper"

RSpec.describe "POST /sessions", type: :request do
  let(:user) { create(:user) }

  before { user }

  context "with valid credentials" do
    it "returns 200 with user info" do
      post "/sessions", params: { email: user.email, pin: "1234" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        "message" => "Login successful",
        "user" => hash_including("id" => user.id, "email" => user.email)
      )
    end
  end

  context "with invalid credentials" do
    it "returns 401 when PIN is wrong" do
      post "/sessions", params: { email: user.email, pin: "0000" }

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Invalid PIN")
    end

    it "returns 401 when email is not found" do
      post "/sessions", params: { email: "unknown@example.com", pin: "1234" }

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Invalid email")
    end
  end

  context "with missing params" do
    it "returns 400 when email is missing" do
      post "/sessions", params: { pin: "1234" }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to include("error" => "email and pin are required")
    end

    it "returns 400 when pin is missing" do
      post "/sessions", params: { email: user.email }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to include("error" => "email and pin are required")
    end

    it "returns 400 when both are missing" do
      post "/sessions", params: {}

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to include("error" => "email and pin are required")
    end
  end
end
