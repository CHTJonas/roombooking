class UsersController < ApplicationController

  # Show all users that are registered.
  def index
    @users = User.accessible_by(current_ability, :read)
  end

  # Show all information stored about a user.
  def show
    @user = User.find(params[:id])
    authorize! :read, @user
  end
end
