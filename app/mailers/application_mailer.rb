# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'roombooking@adctheatre.com'
  layout 'mailer'

  # Overrides the mail method to log outgoing emails.
  def mail(*args)
    msg = super
    Email.create_from_message(msg)
    msg
  end

  # Allow emails to be delivered asynchronously using Sidekiq.
  def self.deliver_async
    klass = self
    wrapper = Class.new do
      def initialize(klass)
        @klass = klass
      end

      def respond_to_missing?(*args)
        true
      end

      def method_missing(method_name, *args)
        MailDeliveryJob.perform_async(@klass, method_name, *args)
      end
    end
    wrapper.new(klass)
  end
end
