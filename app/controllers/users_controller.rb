class UsersController < ApplicationController

  # Show all users that are registered.
  def index
    @users = User.accessible_by(current_ability, :read).page(params[:page])
  end

  # Edit a particular user.
  def edit
    @user = User.find(params[:id])
    authorize! :edit, @user
  end

  # Update a user's fields in the database.
  def update
    @user = User.find(params[:id])
    authorize! :edit, @user
    if @user.update(user_params)
      alert = { 'class' => 'success', 'message' => "Updated user account #{@user.id}!"}
      flash[:alert] = alert
      redirect_to @user
    else
      alert = { 'class' => 'danger', 'message' => @user.errors.full_messages.first }
      flash.now[:alert] = alert
      render :edit
    end
  end

  # Show all information stored about a single user.
  def show
    @user = User.find(params[:id])
    authorize! :read, @user
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :admin, :blocked)
  end
end
