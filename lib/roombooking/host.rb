# frozen_string_literal: true

module Roombooking
  module Host
    class << self
      def name
        ENV['SITE_HOSTNAME'].freeze
      end

      def url(path = nil)
        if path
          "https://#{name}/#{path}".freeze
        else
          "https://#{name}".freeze
        end
      end
    end
  end
end
