# frozen_string_literal: true

module Roombooking
  module Middleware
    class HeaderInserter
      def initialize(app)
        @app = app
      end

      def call(env)
        # Let the app respond to the request first.
        status, headers, response = @app.call(env)

        # Add the software version header.
        headers['X-ADC-Room-Booking-Version'] = Roombooking::Version.git_description

        # Pass the response up the middleware stack.
        [status, headers, response]
      end
    end
  end
end
