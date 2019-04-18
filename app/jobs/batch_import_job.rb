# frozen_string_literal: true

class BatchImportJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform(user_id)
    PaperTrail.request.whodunnit = user_id
    shows = ShowEnumerationService.perform
    shows.each do |camdram_show|
      begin
        # Wrap in a single transaction here so that we either
        # import the show and make its block bookings successfully,
        # or we rollback and ignore that single show.
        ActiveRecord::Base.transaction do
          show = CamdramShow.create_from_camdram(camdram_show)
          show.block_out_bookings(User.find(user_id))
        end
      rescue ActiveRecord::RecordInvalid => e
        # Just skip over the show if it's not valid.
        next
      end
    end
  end
end
