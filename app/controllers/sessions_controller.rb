class SessionsController < ApplicationController
  def create
    if params[:email].blank? || params[:pin].blank?
      return render json: { error: "email and pin are required" }, status: :bad_request
    end

    user = User.find_by(email: params[:email].downcase)

    if user.nil?
      return render json: { error: "Invalid email" }, status: :unauthorized
    end

    if !user.authenticate_pin(params[:pin])
      return render json: { error: "Invalid PIN" }, status: :unauthorized
    end

    render json: {
      message: "Login successful",
      user: { id: user.id, email: user.email }
    }, status: :ok
  end
end
