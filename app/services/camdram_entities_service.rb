module CamdramEntitiesService
  class << self
    def get_authorised(user, impersonator)
      if impersonator.present?
        # User is also an administrator so we don't need to care about their
        # peronal Camdram token as this will use the application token.
        shows = impersonator.authorised_camdram_shows
        societies = impersonator.authorised_camdram_societies
        return [shows, societies]
      else
        # User is genuine.
        shows = user.authorised_camdram_shows
        societies = user.authorised_camdram_societies
        return [shows, societies]
      end
    end
  end
end
