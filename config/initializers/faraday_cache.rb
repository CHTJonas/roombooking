# frozen_string_literal: true

# Reopen the FaradayMiddleware::Caching class and overwrite
# the cache_key method so that we can force plaintext cache keys.
module FaradayMiddleware
  class Caching
    def cache_key(env)
      url = env[:url].dup
      if url.query && params_to_ignore.any?
        params = parse_query url.query
        params.reject! { |k,| params_to_ignore.include? k }
        url.query = params.any? ? build_query(params) : nil
      end
      url.normalize!
      full_key? ? url.host + url.request_uri : url.request_uri
    end
  end
end
