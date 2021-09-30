# frozen_string_literal: true

class BatchImportJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform(user_id, result_id)
    result = BatchImportResult.lock.find(result_id)
    result.update!(started: Time.now)

    PaperTrail.request.whodunnit = user_id
    shows = ShowEnumerationService.perform
    shows_imported_successfully = []
    shows_imported_unsuccessfully = []
    shows_already_imported = []

    shows.each do |camdram_show|
      # First check if the show has already been imported.
      if CamdramShow.find_by(camdram_id: camdram_show.id)
        shows_already_imported << camdram_show.id
        next
      end

      # Now actually import the show, wrapped in a single
      # transaction so that we either import the show and
      # make its block bookings successfully, or we
      # rollback and ignore that single show.
      ActiveRecord::Base.transaction do
        show = CamdramShow.create_from_camdram(camdram_show)
        show.block_out_bookings(User.find(user_id))
      end
      shows_imported_successfully << camdram_show.id
    rescue ActiveRecord::RecordInvalid => e
      shows_imported_unsuccessfully << camdram_show.id
      Sentry.capture_exception(e)
      next
    end

    PaperTrail.request.whodunnit = nil
    result.with_lock do
      result.completed = Time.now
      result.shows_imported_successfully = shows_imported_successfully
      result.shows_imported_unsuccessfully = shows_imported_unsuccessfully
      result.shows_already_imported = shows_already_imported
      result.save!
    end
  end
end
