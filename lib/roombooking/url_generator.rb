# frozen_string_literal: true

module Roombooking
  module UrlGenerator
    class << self
      include Rails.application.routes.url_helpers
      def default_url_options
        ActionMailer::Base.default_url_options
      end
    end
  end
end
