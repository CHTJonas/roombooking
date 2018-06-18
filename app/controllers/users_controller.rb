class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?, :except => [:index]

  # Show all users that are registered
  def index
    @users = User.all
  end

  # Show a user all information stored about themselves
  def show
    @user = User.find(params[:id])
  end

end
