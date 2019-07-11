# frozen_string_literal: true

module Roombooking
  module Middleware
    class RateLimiter
      def initialize(app)
        @app = app
      end

      def call(env)
        # Call Rack::Attack and lower stack middleware first.
        status, headers, response = @app.call(env)

        # Then add the X-RateLimit headers if possible.
        throttle_data = env['rack.attack.throttle_data']
        if throttle_data
          per_ip_throttle_data = throttle_data['requests by ip']
          if per_ip_throttle_data
            count = per_ip_throttle_data[:count]
            period = per_ip_throttle_data[:period]
            limit = per_ip_throttle_data[:limit]
            now = per_ip_throttle_data[:epoch_time]
            time_elapsed = now % period
            time_remaining = period - time_elapsed
            next_period = now + time_remaining
            requests_remaining = limit - count
            requests_remaining = 0 if requests_remaining < 0
            headers['X-RateLimit-Limit'] = limit.to_s
            headers['X-RateLimit-Remaining'] = requests_remaining.to_s
            headers['X-RateLimit-Reset'] = next_period.to_s
            headers['X-RateLimit-Discriminator'] = per_ip_throttle_data[:discriminator]
            headers['Retry-After'] = time_remaining.to_s if count >= limit
          end
        end

        # Pass the response up the middleware stack.
        [status, headers, response]
      end

    end
  end
end
