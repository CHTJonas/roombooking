class SitemapGenerationJob < ApplicationJob
  def perform
    SitemapGenerator::Interpreter.run
    SitemapGenerator::Sitemap.ping_search_engines if Rails.env.production?
  end
end
