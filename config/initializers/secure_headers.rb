SecureHeaders::Configuration.default do |config|
  # Increase security of cookies in order to provide some protection against
  # cross-site request forgery attacks.
  config.cookies = {
    httponly: true,
    samesite: {
      lax: true
    }
  }

  # In production, cookies may only be sent over HTTPS.
  config.cookies.merge!({
    secure: true
  }) if Rails.env.production?

  # HTTP Strict Transport Security is handled upstream by NGINX.
  config.hsts = SecureHeaders::OPT_OUT

  # Attempt to prevent cross-site request forgery attacks as best we can.
  config.x_xss_protection = "1; mode=block"
  config.x_frame_options = "deny"
  config.x_content_type_options = "nosniff"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"

  # Prevent leaking excessive information to third-parties via the refer header.
  config.referrer_policy = "strict-origin-when-cross-origin"

  # Content security policy is handled internally by Rails.
  config.csp = SecureHeaders::OPT_OUT
end
