# frozen_string_literal: true

Rails.application.config.middleware.use Rack::Attack

# Blacklist IPs using the cache
# To add an IP: Rails.cache.write("blocklist 1.2.3.4", true, expires_in: 2.days)
# To remove an IP: Rails.cache.delete("blocklist 1.2.3.4")
Rack::Attack.blocklist("block IP") do |req|
  Rails.cache.read("blocklist #{req.ip}")
end

# Throttle all requests by IP (60rpm)
Rack::Attack.throttle('req/ip', limit: 300, period: 5.minutes) do |req|
  req.ip
end

# Prevent brute-force login attempts
Rack::Attack.throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
  req.path == '/login' and req.ip
end
