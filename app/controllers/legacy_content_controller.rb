# frozen_string_literal: true

class LegacyContentController < ThirdPartyContentController
  # Disable entirely until https://github.com/rails/rails/issues/35137 is resolved.
  content_security_policy false
  # content_security_policy do |policy|
  #   policy.script_src  :self, :unsafe_inline
  #   policy.style_src   :self, :unsafe_inline
  # end
end
