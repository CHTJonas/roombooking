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

        # Add the software version headers.
        headers['X-RoomBooking-Version'] = Roombooking::Version.to_s
        headers['X-RoomBooking-Camdram-Version'] = Camdram::Version.to_s

        # Pass the response up the middleware stack.
        [status, headers, response]
      end
    end
  end
end
