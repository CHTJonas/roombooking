SecureHeaders::Configuration.default do |config|

  # Increase security of cookies in order to provide some protection against
  # cross-site request forgery attacks.
  config.cookies = {
    httponly: true,
    samesite: {
      lax: true
    }
  }

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

  config.csp = {
    # Remove schemes from host sources in order to save bytes and discourage
    # mixed content.
    preserve_schemes: true,

    # Fetch directives
    child_src: %w('none'),
    connect_src: %w('self'),
    default_src: %w('none'),
    font_src: %w('self'),
    frame_src: %w('none'),
    img_src: %w('self' secure.gravatar.com),
    manifest_src: %w('none'),
    media_src: %w('none'),
    object_src: %w('none'),
    prefetch_src: %w('none'),
    script_src: %w('self' 'unsafe-inline'),
    style_src: %w('self' 'unsafe-inline'),
    # webrtc_src: %w('none'),
    worker_src: %w('none'),

    # Document directives
    base_uri: %w('self'),
    plugin_types: %w(),
    sandbox: false,

    # Navigation directives
    form_action: %w('self'),
    frame_ancestors: %w('none'),

    # Reporting directives
    report_uri: %w(https://sentry.io/api/1278887/security/?sentry_key=0a2fb033999d4499bec75801fe55d575),

    # Other directives
    block_all_mixed_content: true,
    upgrade_insecure_requests: true
  }
end
