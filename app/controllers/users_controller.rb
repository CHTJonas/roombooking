# frozen_string_literal: true

class UsersController < ApplicationController
  # Shouldn't be needed as the impersonation route is constrained by
  # Roombooking::AdminConstraint - this is just to be doubly safe.
  before_action :must_be_admin!, only: :impersonate

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
    @user = User.eager_load(:camdram_account).find(params[:id])
    authorize! :read, @user
    begin
      @camdram_shows = @user.authorised_camdram_shows
      @camdram_societies = @user.authorised_camdram_societies
    rescue Roombooking::CamdramAPI::NoAccessToken, Roombooking::CamdramAPI::CamdramError
      alert = { 'class' => 'warning', 'message' => "The was a problem retrieving this user's data from Camdram." }
      flash.now[:alert] = alert
    end
  end

  # Allows and administrator to impersonate a user.
  def impersonate
    # An imposter can't be a double agent!
    @current_user = impersonator if user_is_imposter?
    @user = User.find(params[:id])
    log_abuse "#{@current_user.name.capitalize} started impersonating #{@user.name.capitalize}"
    session[:impersonator_id] = current_user.id
    current_session.invalidate!
    sesh = Session.create(user: @user,
      expires_at: current_session.expires_at,
      login_at: DateTime.now, ip: request.remote_ip,
      user_agent: request.user_agent)
    session[:sesh_id] = sesh.id
    redirect_to @user
  end

  # Stops an impersonation and returns the user to their rightful account.
  def discontinue_impersonation
    if user_is_imposter? && impersonator.admin?
      log_abuse "#{impersonator.name.capitalize} stopped impersonating #{@current_user.name.capitalize}"
      user = impersonator
      current_session.invalidate!
      sesh = Session.create(user: user,
        expires_at: current_session.expires_at,
        login_at: DateTime.now, ip: request.remote_ip,
        user_agent: request.user_agent)
      session[:sesh_id] = sesh.id
      session.delete(:impersonator_id)
      redirect_to user
    else
      redirect_to current_user
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :admin, :blocked)
  end
end
