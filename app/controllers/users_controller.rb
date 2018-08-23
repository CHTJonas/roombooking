class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user

  # Show all users that are registered.
  def index
    @users = User.all
  end

  # Show all information stored about a user.
  def show
    @user = User.find(params[:id])
  end

  private

    # Checks if the user is an administrator, or is accessing their own user page.
    def correct_user
      check_user params[:id] ? User.find(params[:id]) : nil
    end
end
