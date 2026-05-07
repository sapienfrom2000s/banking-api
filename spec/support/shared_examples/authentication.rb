RSpec.shared_examples "requires authentication" do
  context "when Authorization header is missing" do
    it "returns 401" do
      subject
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    end
  end

  context "when token is invalid" do
    it "returns 401" do
      headers["Authorization"] = "Bearer invalidtoken"
      subject
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    end
  end

  context "when token is expired" do
    it "returns 401" do
      expired_token = JwtService.encode({ user_id: 1, exp: 1.hour.ago.to_i })
      headers["Authorization"] = "Bearer #{expired_token}"
      subject
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    end
  end
end
