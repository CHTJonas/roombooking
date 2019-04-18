# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                   :bigint(8)        not null, primary key
#  name                 :string           not null
#  email                :string           not null
#  admin                :boolean          default(FALSE), not null
#  sysadmin             :boolean          default(FALSE), not null
#  blocked              :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  confirmation_token   :string
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  unconfirmed_email    :string
#  sign_in_count        :integer          default(0), not null
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :inet
#  last_sign_in_ip      :inet
#

class User < ApplicationRecord
  include PgSearch

  has_paper_trail
  devise :confirmable, :trackable, :timeoutable, :invalidatable,
    :omniauthable, omniauth_providers: [:camdram]
  pg_search_scope :search_by_name_and_email, against: [:name, :email],
    ignoring: :accents, using: { tsearch: { prefix: true, dictionary: 'english' },
    dmetaphone: { any_word: true }, trigram: { only: [:name] } }

  has_many :user_sessions, dependent: :destroy
  has_many :booking, dependent: :destroy
  has_many :provider_account, dependent: :delete_all
  has_one :camdram_account, -> { where(provider: 'camdram') }, class_name: 'ProviderAccount'
  has_many :camdram_token, dependent: :delete_all
  has_one :latest_camdram_token, -> { order(created_at: :desc) }, class_name: 'CamdramToken'

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, email: true

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

  # Grants administrator privileges to the user.
  def make_admin!
    self.update(admin: true)
  end

  # Revokes administrator privileges from the user.
  def revoke_admin!
    self.update(admin: false)
  end

  # Blocks the user.
  def block!
    self.update(blocked: true)
  end

  # Unblocks the user.
  def unblock!
    self.update(blocked: false)
  end

  # Invalidates all the user's existing login sessions.
  def logout_everywhere!
    user_sessions.destroy_all
  end

  # Returns the user's Camdram uid.
  def camdram_id
    self.camdram_account.try(:uid)
  end

  def authorised_camdram_shows
    if self.admin
      # Admins are authorised for all active shows that haven't been marked
      # as dormant (which happens at the start of each new term).
      CamdramShow.where(dormant: false, active: true)
    else
      begin
        # Poll Camdram for future shows that the user has access to.
        shows = camdram_client.user.get_shows
        shows.reject! { |show| show.performances.last.end_date < Time.now }
        # Then authorise any such active shows that are not dormant.
        CamdramShow.where(camdram_id: shows.map(&:id), dormant: false, active: true)
      rescue Roombooking::CamdramAPI::NoAccessToken => e
        raise e
      rescue
        raise Roombooking::CamdramAPI::CamdramError
      end
    end
  end

  def authorised_camdram_societies
    if self.admin
      # Admins are authorised for all active societies.
      CamdramSociety.where(active: true)
    else
      begin
        # Poll Camdram for any societies that the user has access to.
        societies = camdram_client.user.get_societies
        # Then authorise any such active societies.
        CamdramSociety.where(camdram_id: societies.map(&:id), active: true)
      rescue Roombooking::CamdramAPI::NoAccessToken => e
        raise e
      rescue
        raise Roombooking::CamdramAPI::CamdramError
      end
    end
  end

  private

  # Private method to create a Camdram client with the user's OAuth access
  # token. This client will be able to act as the user and view the list of
  # shows and societies the user administers.
  def camdram_client
    token = latest_camdram_token
    raise Roombooking::CamdramAPI::NoAccessToken, 'No Camdram tokens found for the user' unless token.present?
    token_hash = { access_token: token.access_token,
      refresh_token: token.refresh_token, expires_at: token.expires_at }
    Roombooking::CamdramAPI::ClientFactory.new(token_hash)
  end

end
