# frozen_string_literal: true

Rails.application.config.middleware.use Roombooking::Middleware::RateLimiter
Rails.application.config.middleware.use Rack::Attack

Rack::Attack.cache.prefix = 'rack-attack'

# Accept from allowlist.
Rack::Attack.safelist('allowlist-by-ip') do |req|
  '127.0.0.1' == req.ip || '::1' == req.ip ||
    Rails.cache.read("#{Rack::Attack.cache.prefix}:allowlist:#{req.ip}")
end

# Reject from blocklist.
Rack::Attack.blocklist('blocklist-by-ip') do |req|
  Rails.cache.read("#{Rack::Attack.cache.prefix}:blocklist:#{req.ip}")
end

# Limit all IP addresses to 60rpm.
Rack::Attack.throttle('requests-by-ip', limit: 300, period: 5.minutes) do |req|
  req.ip
end

# Prevent brute-force login or 2FA attempts.
Rack::Attack.throttle('logins-by-ip', limit: 5, period: 20.seconds) do |req|
  if req.path == '/login' || req.path == '/auth/2fa'
    req.ip
  end
end

# Block suspicious requests for '/etc/password' or Wordpress-specific paths.
Rack::Attack.throttle('bots-by-ip', limit: 3, period: 5.minutes) do |req|
  if CGI.unescape(req.query_string) =~ %r{/etc/passwd} || req.path.include?('/etc/passwd') ||
    req.path.include?('wp-admin') || req.path.include?('wp-login')
    req.ip
  end
end

ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, req|
  request = req[:request]
  match = request.env['rack.attack.matched']
  ip = request.ip
  ua = request.user_agent
  str = %Q(Throttled client due to match "#{match}" : [#{ip} - #{ua}])
  Yell['abuse'].info(str)
end
