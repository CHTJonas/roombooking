# frozen_string_literal: true

class SlackWebhookValidator < ActiveModel::EachValidator
  @@slack_webhook_regexp = %r{https?://hooks.slack.com/services/.+}i

  def validate_each(record, attribute, value)
    unless value.blank? || value =~ @@slack_webhook_regexp
      record.errors.add(attribute, options[:message] || 'is not a valid Slack webhook URL')
    end
  end
end
