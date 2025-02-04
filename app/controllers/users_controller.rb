class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      render json: { message: "User created successfully", user: @user }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    @users = User.all
    render json: @users, status: :ok
  end

  def show
    @user = User.find(params[:id])
    render json: @user, status: :ok
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      render json: { message: "User deleted successfully" }, status: :ok
    else
      render json: { errors: [ "Failed to delete user" ] }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password)
  end
end
