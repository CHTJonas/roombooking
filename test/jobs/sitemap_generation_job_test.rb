require 'test_helper'

class SitemapGenerationJobTest < ActiveJob::TestCase
  setup do
    sitemap_file.delete if sitemap_file.exist?
  end

  test "should generate sitemap" do
    assert_not File.exist?(sitemap_file)
    assert_equal 0, SitemapGenerationJob.jobs.size
    SitemapGenerationJob.perform_async
    assert_equal 1, SitemapGenerationJob.jobs.size
    SitemapGenerationJob.drain
    assert_equal 0, SitemapGenerationJob.jobs.size
    assert File.exist?(sitemap_file)
  end

  private

  def sitemap_file
    @sitemap_file ||= Rails.root.join('public', 'sitemaps', 'sitemap.xml.gz')
  end
end
