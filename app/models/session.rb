class Session < ActiveRecord::Base
  belongs_to :user

  validates :expires_at, presence: true
  validates :login_at, presence: true
  validates :ip, presence: true
  validates :user_agent, presence: true

  # True if the Session has expired, false otherwise.
  def expired?
    Time.now >= self.expires_at
  end
end
