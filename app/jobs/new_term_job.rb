# frozen_string_literal: true

class NewTermJob
  include Sidekiq::Worker
  sidekiq_options queue: 'roombooking_jobs'

  # concurrency 1, drop: true

  def perform
    CamdramShow.all.each do |show|
      show.update(dormant: true)
    end
  end
end
