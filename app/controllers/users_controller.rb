# frozen_string_literal: true

class UsersController < ApplicationController
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
      alert = { 'class' => 'success', 'message' => 'Account updated!' }
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

  # Validates a user's account fro the first time when created.
  def validate
    @user = User.find(params[:id])
    if @user.validate(params[:token])
      log_abuse "#{@user.to_log_s} validated their account"
      alert = { 'class' => 'success', 'message' => 'You have successfully validated your user account! Please now login.' }
      flash[:alert] = alert
      redirect_to root_path
    else
      log_abuse "#{@user.to_log_s} attempted to validated their account, but failed"
      alert = { 'class' => 'danger', 'message' => 'Something went wrong when validating your user account.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: { reason: 'user validation failed' }, status: :forbidden
    end
  end

  # Allows and administrator to impersonate a user.
  def impersonate
    # An imposter can't be a double agent!
    @current_user = current_imposter if user_is_imposter?
    @user = User.find(params[:id])
    log_abuse "#{@current_user.to_log_s} started impersonating #{@user.to_log_s}"
    session[:imposter_id] = current_user.id
    current_session.invalidate!
    sesh = Session.create(user: @user,
                          expires_at: current_session.expires_at,
                          login_at: Time.zone.now, ip: request.remote_ip,
                          user_agent: request.user_agent)
    session[:sesh_id] = sesh.id
    redirect_to @user
  end

  # Stops an impersonation and returns the user to their rightful account.
  def discontinue_impersonation
    if user_is_imposter? && current_imposter.admin?
      log_abuse "#{current_imposter.to_log_s} stopped impersonating #{@current_user.to_log_s}"
      user = current_imposter
      current_session.invalidate!
      sesh = Session.create(user: user,
                            expires_at: current_session.expires_at,
                            login_at: Time.zone.now, ip: request.remote_ip,
                            user_agent: request.user_agent)
      session[:sesh_id] = sesh.id
      session.delete(:imposter_id)
      redirect_to user
    else
      redirect_to current_user
    end
  end

  private

  def user_params
    if user_is_admin?
      params.require(:user).permit(:name, :email, :admin, :blocked)
    else
      params.require(:user).permit(:name, :email)
    end
  end
end
