class CamdramToken < ActiveRecord::Base
  belongs_to :user

  # Create a CamdramToken model object from a OmniAuth::AuthHash object.
  def self.create_with_credentials(creds, user)
    create! do |cdtkn|
      cdtkn.access_token = creds[:token]
      cdtkn.refresh_token = creds[:refresh_token]
      cdtkn.expires_at = creds[:expires_at]
      cdtkn.user = user
    end
  end

  # True if the Camdram API token has expired, false otherwise
  def expired?
    Time.now.to_i >= self.expires_at
  end
end
