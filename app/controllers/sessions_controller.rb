# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  def new
    redirect_to user_camdram_omniauth_authorize_path
  end
end
