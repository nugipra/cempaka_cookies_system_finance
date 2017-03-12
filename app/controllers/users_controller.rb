class UsersController < ApplicationController

  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update_password
    @user = User.find(current_user.id)
    if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case their password changed
      bypass_sign_in(@user)
      notice = params[:user][:password].blank? ? "Password is not changed because you didn't enter new password" : "Password has succesfully updated"
      redirect_to edit_user_path, notice: notice
    else
      render "edit"
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end
end