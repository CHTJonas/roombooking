# frozen_string_literal: true

module Roombooking
  module Middleware
    class PublicCacheManager
      def initialize(app)
        @app = app
      end

      def call(env)
        # Let the app respond to the request first.
        status, headers, response = @app.call(env)

        # Add an appropriate Vary header.
        headers['Vary'] = 'Accept-Encoding'

        # Then modify the headers if we need to.
        if uncachable_paths.any? { |path| env['PATH_INFO'].include?(path) }
          headers['Cache-Control'] = 'no-store'
          headers.except!('Expires', 'Vary', 'ETags', 'Last-Modified')
        end

        # Pass the response up the middleware stack.
        [status, headers, response]
      end

      private

      def uncachable_paths
        @@uncachable_paths ||= ['sitemaps', 'robots.txt']
      end
    end
  end
end
