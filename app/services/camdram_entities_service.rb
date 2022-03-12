# frozen_string_literal: true

class CamdramEntitiesService < ApplicationService
  attr_reader :shows, :societies

  def initialize(user, login_user)
    @user = user
    @login_user = login_user
  end

  def perform
    if @user.nil?
      @shows = @societies = []
      return
    end
    if @login_user.present?
      @shows = @login_user.camdram_shows
      @societies = @login_user.camdram_societies
    else
      @shows = @user.camdram_shows
      @societies = @user.camdram_societies
    end
  end
end
