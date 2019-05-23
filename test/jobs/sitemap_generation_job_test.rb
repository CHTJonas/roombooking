require 'test_helper'

class SitemapGenerationJobTest < ActiveJob::TestCase
  test "should generate sitemap" do
    sitemap_file = Rails.root.join('public', 'sitemaps', 'sitemap.xml.gz')
    assert_not File.exist?(sitemap_file)
    assert_equal 0, SitemapGenerationJob.jobs.size
    SitemapGenerationJob.perform_async
    assert_equal 1, SitemapGenerationJob.jobs.size
    SitemapGenerationJob.drain
    assert_equal 0, SitemapGenerationJob.jobs.size
    assert File.exist?(sitemap_file)
    File.delete(sitemap_file) if File.exist?(sitemap_file)
  end
end
