# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'roombooking@adctheatre.com'
  layout 'mailer'

  # Allow emails to be delivered asynchronously using Sidekiq.
  def self.deliver_async
    wrapper = Class.new do
      def initialize(klass)
        @klass = klass
      end

      def respond_to_missing?(method, *args)
        @klass.action_methods.include? method.to_s || super
      end

      def method_missing(method, *args)
        if @klass.action_methods.include? method.to_s
          MailDeliveryJob.perform_async(@klass.to_s, method.to_s, *args)
        else
          super
        end
      end
    end
    wrapper.new(self)
  end
end
