# frozen_string_literal: true

class NewTermJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform(user_id)
    PaperTrail.request.whodunnit = user_id
    CamdramShow.all.each do |show|
      show.update(dormant: true)
    end
  end
end
