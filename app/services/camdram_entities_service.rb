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
      @shows = @current_imposter.camdram_shows
      @societies = @current_imposter.camdram_societies
    else
      @shows = @user.camdram_shows
      @societies = @user.camdram_societies
    end
  end
end
