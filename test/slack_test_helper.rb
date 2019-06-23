module SlackTestHelper
  def validates_slack_webhook(o)
    invalid_urls = %w{
      blah
      https://www.google.co.uk
      http://slack.com https://slack.com
      http://slack.com/test https://slack.com/test
      http://slack.com/services https://slack.com/services
      http://hooks.slack.com https://hooks.slack.com
      http://slack.com/services/X51Y67D2B/GHT0QDP2N/7NURc2dUB8m5N8A7sqVUvL6a
      https://slack.com/services/X51Y67D2B/GHT0QDP2N/7NURc2dUB8m5N8A7sqVUvL6a
      http://hooks.slack.com/X51Y67D2B/GHT0QDP2N/7NURc2dUB8m5N8A7sqVUvL6a
      https://hooks.slack.com/X51Y67D2B/GHT0QDP2N/7NURc2dUB8m5N8A7sqVUvL6a
    }
    invalid_urls.each do |url|
      o.slack_webhook = url
      assert_not o.save
    end
    valid_urls = %w{
      http://hooks.slack.com/services/X51Y67D2B/GHT0QDP2N/7NURc2dUB8m5N8A7sqVUvL6a,
      https://hooks.slack.com/services/X51Y67D2B/GHT0QDP2N/7NURc2dUB8m5N8A7sqVUvL6a
    }
    valid_urls.each do |url|
      o.slack_webhook = url
      assert o.save
    end

    # We end up creating a Camdram entity so we need to remove the generated
    # cache warmup jobs.
    CamdramEntityCacheWarmupJob.clear
  end
end
