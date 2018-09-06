class User < ApplicationRecord
  has_many :log_events, as: :logable, :dependent => :delete_all
  has_many :booking
  has_many :camdram_token

  # Create a User model object from an omniauth authentication object.
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
      end
    end
  end

  # Grants site administrator privileges to the user.
  def make_admin!
    self.admin = true
  end

  # Revokes site administrator privileges from the user.
  def revoke_admin!
    self.admin = false
  end

end
