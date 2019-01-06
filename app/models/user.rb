class User < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_name_and_email,
                   against: [:name, :email],
                   ignoring: :accents,
                   using: {
                     tsearch: {
                       prefix: true,
                       dictionary: 'english'
                     },
                     dmetaphone: {
                       any_word: true
                     },
                     trigram: {
                       only: [:name]
                     },
                   }

  has_many :log_events, as: :logable, dependent: :delete_all
  has_many :provider_account, dependent: :delete_all
  has_many :camdram_token, dependent: :delete_all
  has_many :booking, dependent: :delete_all

  validates :name, presence: true
  validates :email, uniqueness: true

  # Create a User model object from an omniauth authentication object.
  def self.from_provider(auth)
    name = auth['info']['name'] || ''
    email = auth['info']['email'] || ''
    user = User.find_by(email: email)
    ActiveRecord::Base.transaction do
      unless user.present?
        user = User.new
        user.name = name
        user.email = email
        user.save
      end
      provider_account = ProviderAccount.new
      provider_account.provider = auth['provider']
      provider_account.uid = auth['uid']
      provider_account.user_id = user.id
      provider_account.save
    end
    user
  end

  # Grants site administrator privileges to the user.
  def make_admin!
    self.admin = true
    self.save
  end

  # Revokes site administrator privileges from the user.
  def revoke_admin!
    self.admin = false
    self.save
  end

  # Returns the last CamdramToken object stored in the database that belongs
  # to the user.
  def latest_camdram_token
    return self.camdram_token.order(created_at: :desc).first
  end

  def authorised_camdram_shows
    if self.admin
      # Admins are authorised for all active shows!
      CamdramProduction.where(active: true)
    else
      # Poll Camdram for future shows that the user has access to.
      shows = camdram.user.get_shows.reject {
        |show| show.performances.last.end_date < Time.now
      }
      # Then authorise any such active shows.
      CamdramProduction.where(camdram_id: shows, active: true)
    end
  end

  def authorised_camdram_societies
    if self.admin
      # Admins are authorised for all active societies!
      CamdramSociety.where(active: true)
    else
      # Poll Camdram for any societies that the user has access to.
      societies = camdram.user.get_societies
      # Then authorise any such active societies.
      CamdramSociety.where(camdram_id: societies, active: true)
    end
  end

  private

  # Private method to create a Camdram client with the user's OAuth access
  # token. This client will be able to act as the user and view the list of
  # shows and societies the user administers.
  def camdram
    Camdram::Client.new do |config|
      token = latest_camdram_token
      token_hash = {access_token: token.access_token, refresh_token: token.refresh_token, expires_at: token.expires_at}
      app_id = Rails.application.credentials.dig(:camdram, :app_id)
      app_secret = Rails.application.credentials.dig(:camdram, :app_secret)
      config.auth_code(token_hash, app_id, app_secret)
      config.user_agent = "ADC Room Booking System/#{Roombooking::VERSION}"
      config.base_url = "https://www.camdram.net"
    end
  end

end
