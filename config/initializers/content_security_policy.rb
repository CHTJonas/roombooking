# frozen_string_literal: true

Rails.application.config.content_security_policy do |policy|
  policy.default_src     :none
  policy.img_src         :self, "https://secure.gravatar.com"
  policy.script_src      :self, "https://www.google.com/recaptcha/", "https://www.gstatic.com/recaptcha/", "https://www.recaptcha.net/recaptcha/api.js"
  policy.frame_src       "https://www.google.com/recaptcha/"
  policy.style_src       :self, :unsafe_inline
  policy.font_src        :self
  policy.connect_src     :self, "https://sentry.io"
  policy.form_action     :self, "https://www.camdram.net"
  policy.frame_ancestors :none
  policy.base_uri        :none
  policy.block_all_mixed_content

  if ENV['CSP_REPORT_URI'].present?
    policy.report_uri      ENV['CSP_REPORT_URI']
  end

  if Rails.env.production?
    policy.upgrade_insecure_requests
  end
end

# Enable automatic crytographic nonce generation for UJS.
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Don't enforce CSP but report violations instead.
Rails.application.config.content_security_policy_report_only = true
