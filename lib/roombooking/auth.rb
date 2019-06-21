# frozen_string_literal: true

module Roombooking
  module Auth
    extend ActiveSupport::Concern

    included do
      before_action :check_user!
      before_action :handle_2fa!
      helper_method :current_user
      helper_method :current_imposter
      helper_method :true_user
      helper_method :user_logged_in?
      helper_method :user_fully_authenticated?
      helper_method :user_is_admin?
      helper_method :user_is_imposter?
    end

    # Returns the current session.
    def current_session
      begin
        @current_session ||= Session
          .eager_load(user: :latest_camdram_token)
          .find(session[:sesh_id]) if session[:sesh_id]
      rescue Exception => e
        nil
      end
    end

    # Returns the user who is currently logged in, or nil otherwise.
    def current_user
      @current_user ||= current_session.try(:user)
    end

    # Returns the imposter who is currently logged in, or nil otherwise.
    def current_imposter
      begin
        @current_imposter ||= User.find(session[:imposter_id]) if session[:imposter_id]
      rescue Exception => e
        nil
      end
    end

    # Returns the true user who is currently logged in, or nil if otherwise.
    def true_user
      current_imposter || current_user
    end

    # Returns the current user's most recent Camdram OAuth2 token.
    def current_camdram_token
      @current_camdram_token ||= current_user.try(:latest_camdram_token)
    end

    # True if the user is signed in, false otherwise.
    def user_logged_in?
      current_user.present?
    end

    # True if the user is fully authenticated, false otherwise.
    def user_fully_authenticated?
      user_logged_in? && two_factor_authenticated?
    end

    # True if the user is a site administrator, false otherwise.
    def user_is_admin?
      user_logged_in? && current_user.admin?
    end

    # True if the user is being impersonated, false otherwise.
    def user_is_imposter?
      user_logged_in? && current_imposter.present?
    end

    # True if the user has authenticated using 2FA, false otherwise.
    def two_factor_authenticated?
      if user_logged_in? && true_user.two_factor_token.try(:verified?)
        session[:two_factor_auth].present?
      else
        true
      end
    end

    # Ensure that a user has a valid session, account and Camdram API token.
    def check_user!
      ensure_user_is_not_blocked!
      ensure_session_is_valid!
      ensure_session_is_current!
      return if user_is_imposter?
      ensure_camdram_token_is_present!
      ensure_camdram_token_is_valid!
    end

    def handle_2fa!
      unless two_factor_authenticated?
        alert = { 'class' => 'info', 'message' => 'You need to complete two-factor authentication in order to login.' }
        flash[:alert] = alert
        redirect_to "#{auth_2fa_path}?origin=#{ERB::Util.url_encode(request.path)}"
      end
    end

    # Forces user logout if the user's account has been blocked.
    def ensure_user_is_not_blocked!
      if user_logged_in? && true_user.blocked?
        log_abuse "Forced logout of #{current_user.name.possessive} session with id #{current_session.id} as their account was blocked"
        invalidate_session
        alert = { 'class' => 'danger', 'message' => 'Your account has been blocked by an administrator. Please try again later.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'user blocked'}, status: :unauthorized and return
      end
    end

    # Forces user logout if the user's session has been invalidated.
    def ensure_session_is_valid!
      if user_logged_in? && current_session.invalidated?
        log_abuse "Forced logout of #{current_user.name.possessive} session with id #{current_session.id} as it was invalidated"
        invalidate_session
        alert = { 'class' => 'warning', 'message' => 'Your session has been invalidated by yourself or an administrator. Please login again.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'session invalidated'}, status: :unauthorized and return
      end
    end

    # Forces user logout if the user's session has expired.
    def ensure_session_is_current!
      if user_logged_in? && current_session.expired?
        log_abuse "Forced logout of #{current_user.name.possessive} session with id #{current_session.id} as it had expired"
        invalidate_session
        alert = { 'class' => 'warning', 'message' => 'Your session has expired. Please login again.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'session expired'}, status: :unauthorized and return
      end
    end

    # Forces user logout if the user has no Camdram token.
    def ensure_camdram_token_is_present!
      if user_logged_in? && current_camdram_token.nil?
        log_abuse "Forced logout of #{current_user.name.possessive} session with id #{current_session.id} as no current Camdram token was found"
        invalidate_session
        alert = { 'class' => 'danger', 'message' => 'A Camdram OAuth token error has occured. Please logout and then login again.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'camdram token not present'}, status: :internal_server_error and return
      end
    end

    # Attempts to renew the user's Camdram token if it has expired, and forces
    # user logout if this is not possible.
    def ensure_camdram_token_is_valid!
      if user_logged_in? && current_camdram_token.expired?
        if current_camdram_token.refreshable?
          current_camdram_token.refresh
        else
          log_abuse "Forced logout of #{current_user.name.possessive} session with id #{current_session.id} as the Camdram token was expired and couldn't be refreshed"
          invalidate_session
          alert = { 'class' => 'warning', 'message' => 'Your session has expired. Please login again.' }
          flash.now[:alert] = alert
          render 'layouts/blank', locals: {reason: 'unrefreshable expired camdram token'}, status: :unauthorized and return
        end
      end
    end

    # Ensures the user is an administrator.
    def must_be_admin!
      raise CanCan::AccessDenied, 'user is not an administrator' unless user_is_admin?
    end

    # Simulates a user logoff.
    def invalidate_session
      current_session.try(:invalidate!)
      reset_session
      @current_session = nil
      @current_user = nil
      @current_imposter = nil
      @current_camdram_token = nil
    end
  end
end
