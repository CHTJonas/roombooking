# frozen_string_literal: true

class CamdramEntitiesService < ApplicationService
  attr_reader :shows, :societies

  def initialize(user, current_imposter)
    @user = user
    @current_imposter = current_imposter
  end

  def perform
    if @user.nil?
      @shows = @societies = []
      return
    end
    if @current_imposter.present?
      # User is also an administrator so we don't need to care about their
      # peronal Camdram token as this will use the application token.
      @shows = @current_imposter.authorised_camdram_shows
      @societies = @current_imposter.authorised_camdram_societies
    else
      # User is genuine.
      @shows = @user.authorised_camdram_shows
      @societies = @user.authorised_camdram_societies
    end
  end
end
