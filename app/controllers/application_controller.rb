class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    token = request.headers["Authorization"]&.split(" ")&.last
    payload = JwtService.decode(token)

    if payload.nil?
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end

    @current_user = User.find_by(id: payload["user_id"])

    if @current_user.nil?
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end
  end
end
