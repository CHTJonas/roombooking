# frozen_string_literal: true

module Auth
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :authenticate_user!, raise: false

    def auth
      auth = request.env['omniauth.auth']
      user = ProviderAccount.find_by(provider: auth['provider'], uid: auth['uid'].to_s).try(:user) || User.from_provider(auth)
      # Log the event and render/redirect.
      if user.blocked?
        log_abuse "#{user.name} attempted to login but their account is blocked"
        user = nil
        alert = { 'class' => 'danger', 'message' => 'Your account has been temporarily blocked. Please try again later.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'user blocked'}, status: :forbidden
      elsif !user.confirmed?
        log_abuse "#{user.name} attempted to login but their account is blocked"
        user = nil
        alert = { 'class' => 'danger', 'message' => 'You need to verify your email address before you can login.' }
        flash[:alert] = alert
        redirect_to new_user_confirmation_path
      else
        # Create a record to store the Camdram API token.
        camdram_token = CamdramToken.create_with_credentials(auth['credentials'], user)

        # Make a note of the login to track any abuse.
        log_abuse "#{user.name} successfully logged in with camdram token #{camdram_token.id}"

        alert = { 'class' => 'success', 'message' => 'You have successfully logged in.' }
        flash[:alert] = alert
        sign_in_and_redirect(user)
      end
    end

    # Gracefully handle OAuth failures.
    def failure
      message = params[:message]
      if message == 'csrf_detected'
        raise ActionController::InvalidAuthenticityToken
      elsif message == 'access_denied'
        log_abuse 'User declined to login at Camdram prompt screen'
        alert = { 'class' => 'warning', 'message' => "Login gracefully declined." }
        flash[:alert] = alert
        redirect_to root_url
      else
        log_abuse "A login authentication system error occurred: #{message.humanize}"
        alert = { 'class' => 'danger', 'message' => "Authentication error. Please contact support and quote the following error: #{message.humanize}." }
        flash[:alert] = alert
        render 'layouts/blank', locals: {reason: 'oauth2 failure'}, status: :internal_server_error
      end
      super
     end

    alias_method :camdram, :auth
  end
end
