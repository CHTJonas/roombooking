# frozen_string_literal: true

class SitemapGenerationJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 },
                   threshold: { limit: 5, period: 1.day }

  def perform
    SitemapGenerator::Interpreter.run
    SitemapGenerator::Sitemap.ping_search_engines if Rails.env.production?
  end
end
