# frozen_string_literal: true

class BatchImportJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform(user_id, result_id)
    result = BatchImportResult.lock.find(result_id)
    result.update!(started: Time.now)

    user = User.find(user_id)
    Sentry.set_user({ id: user.id, name: user.name, email: user.email })
    PaperTrail.request.whodunnit = user_id

    shows = ShowEnumerationService.perform
    shows_imported_successfully = []
    shows_imported_unsuccessfully = []
    shows_already_imported = []

    shows.each do |camdram_show|
      # First check if the show has already been imported
      # and if it has, we skip to the next one.
      if CamdramShow.find_by(camdram_id: camdram_show.id)
        shows_already_imported << camdram_show.id
        next
      end

      # Show needs importing, so actually import it.
      CamdramShow.create_from_camdram(camdram_show).block_out_bookings(user)
      shows_imported_successfully << camdram_show.id
    rescue => e
      shows_imported_unsuccessfully << camdram_show.id
      Sentry.set_extras({ camdram_id: camdram_show.id })
      Sentry.capture_exception(e)
      next
    end

    PaperTrail.request.whodunnit = nil
    UserPermissionRefreshJob.perform_async
    result.with_lock do
      result.completed = Time.now
      result.shows_imported_successfully = shows_imported_successfully
      result.shows_imported_unsuccessfully = shows_imported_unsuccessfully
      result.shows_already_imported = shows_already_imported
      result.save!
    end
  end
end
