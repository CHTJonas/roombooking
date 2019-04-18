# frozen_string_literal: true

class CamdramEntitiesService < ApplicationService
  attr_reader :shows, :societies

  def initialize(user, true_user)
    @user = user
    @true_user = true_user
  end

  def perform
    if @user.nil?
      @shows = @societies = []
      return
    end
    if @true_user.present?
      # User is also an administrator so we don't need to care about their
      # peronal Camdram token as this will use the application token.
      @shows = @true_user.authorised_camdram_shows
      @societies = @true_user.authorised_camdram_societies
    else
      # User is genuine.
      @shows = @user.authorised_camdram_shows
      @societies = @user.authorised_camdram_societies
    end
  end
end
