class AuthenticationController < ApplicationController
  def create
    user = User.find_by("username", params[:username])

    if user && user.authenticate(params[:password])
      token = generate_jwt(user)
      render json: { token: token }, status: :ok
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  private

  def generate_jwt(user)
    JWT.encode(
      { user_id: user.username, exp: 24.hours.from_now.to_i },
      ENV["JWT_SECRET"]
    )
  end
end
