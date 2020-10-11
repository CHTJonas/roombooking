# frozen_string_literal: true

module Roombooking
  module Host
    class << self
      def name
        ENV['SITE_HOSTNAME']
      end

      def url(path = nil)
        if path
          "https://#{name}/#{path}"
        else
          "https://#{name}"
        end
      end
    end
  end
end
