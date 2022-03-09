# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :must_be_admin!, only: :impersonate

  def index
    @users = User.accessible_by(current_ability, :read).page(params[:page])
  end

  def edit
    @user = User.find(params[:id])
    authorize! :edit, @user
  end

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

  def show
    @user = User.find(params[:id])
    authorize! :read, @user
  end

  # Validates a user's email when their account is first created.
  def validate
    user = User.find(params[:id])
    if user.validate(params[:token])
      log_abuse "#{user.to_log_s} validated their account"
      alert = { 'class' => 'success', 'message' => 'You have successfully validated your user account! Please now login.' }
      flash[:alert] = alert
      redirect_to root_path
    else
      log_abuse "#{user.to_log_s} attempted to validated their account, but failed"
      alert = { 'class' => 'danger', 'message' => 'Something went wrong when validating your user account.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: { reason: 'user validation failed' }, status: :forbidden
    end
  end

  # Allows an administrator to impersonate a user.
  def impersonate
    new_user = User.find(params[:id])
    log_abuse "#{current_user.to_log_s} started impersonating #{new_user.to_log_s}"
    session[:uid] = new_user.id
    redirect_to new_user
  end

  # Stops an impersonation and returns the user to their rightful account.
  def discontinue_impersonation
    if user_being_impersonated?
      log_abuse "#{login_user.to_log_s} stopped impersonating #{current_user.to_log_s}"
      session[:uid] = login_user.id
    end
    redirect_to current_user # This may still refer to the user being impersonated.
  end

  # Forces a logout everywhere the user is currently logged in by invalidating all active sessions.
  def logout_everywhere
    @user = User.find(params[:id])
    authorize! :edit, @user
    log_abuse "#{login_user.to_log_s} successfully triggered a log out of all current login sessions for #{@user.to_log_s} from the session with ID #{current_session.id}"
    Session.where(user: @user, invalidated: false).map(&:invalidate!)
    alert = { 'class' => 'success', 'message' => "#{@user.name} has been logged out of all their sessions." }
    flash[:alert] = alert
    redirect_to root_url
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
