# frozen_string_literal: true

class SitemapGenerationJob
  include Sidekiq::Worker
  sidekiq_options queue: 'roombooking_jobs'

  # throttle threshold: 5, period: 1.day, drop: true
  # concurrency 1, drop: true

  def perform
    SitemapGenerator::Interpreter.run
    # We're deploying to roombooking-dev.adctheatre.com so don't actually
    # notify any search engines for the time being. Re-enable this when when
    # we deploy proper.
    # SitemapGenerator::Sitemap.ping_search_engines if Rails.env.production?
  end
end
