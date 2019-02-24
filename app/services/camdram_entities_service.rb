class CamdramEntitiesService < ApplicationService
  attr_reader :shows, :societies

  def initialize(user, impersonator)
    @user = user
    @impersonator = impersonator
  end

  def perform
    if @impersonator.present?
      # User is also an administrator so we don't need to care about their
      # peronal Camdram token as this will use the application token.
      @shows = @impersonator.authorised_camdram_shows
      @societies = @impersonator.authorised_camdram_societies
    else
      # User is genuine.
      @shows = @user.authorised_camdram_shows
      @societies = @user.authorised_camdram_societies
    end
  end
end
