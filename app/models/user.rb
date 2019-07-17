# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id               :bigint           not null, primary key
#  name             :string           not null
#  email            :string           not null
#  admin            :boolean          default(FALSE), not null
#  sysadmin         :boolean          default(FALSE), not null
#  blocked          :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  validated_at     :datetime
#  validation_token :string
#  last_login       :datetime
#

class User < ApplicationRecord
  has_paper_trail
  include PgSearch::Model
  pg_search_scope :search_by_name_and_email, against: [:name, :email],
    ignoring: :accents, using: { tsearch: { prefix: true, dictionary: 'english' },
    dmetaphone: { any_word: true }, trigram: { only: [:name] } }

  has_many :bookings, dependent: :destroy
  has_many :provider_accounts, dependent: :delete_all
  has_one :camdram_account, -> { where(provider: 'camdram') }, class_name: 'ProviderAccount'
  has_many :camdram_tokens, dependent: :delete_all
  has_one :latest_camdram_token, -> { order(created_at: :desc) }, class_name: 'CamdramToken'
  has_one :two_factor_token, dependent: :delete

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, email: true
  validate :email_verification_state_must_be_valid

  before_validation :generate_validation_token, on: :create
  after_create_commit do |user|
    EmailVerificationMailer.deliver_async.notify(user.id)
  end

  def generate_validation_token
    unless self.validated_at.present?
      self.validation_token = SecureRandom.alphanumeric(48)
    end
  end

  # Returns a user from an OmniAuth::AuthHash.
  def self.from_omniauth(auth_hash)
    provider = auth_hash['provider'].to_s
    uid = auth_hash['uid'].to_s
    account = ProviderAccount.find_by(provider: provider, uid: uid)
    if account.present?
      account.user
    else
      name = auth_hash['info']['name'] || ''
      email = auth_hash['info']['email'] || ''
      user = User.find_by(email: email)
      ActiveRecord::Base.transaction do
        user = User.create!(name: name, email: email) unless user.present?
        ProviderAccount.create!(provider: provider, uid: uid, user: user)
      end
      user
    end
  end

  # Grants administrator privileges to the user.
  def make_admin!
    self.update(admin: true)
  end

  # Revokes administrator privileges from the user.
  def revoke_admin!
    self.update(admin: false)
  end

  # Blocks the user and invalidates all their sessions.
  def block!
    self.update(blocked: true)
    Session.where(user_id: self.id).each(&:invalidate!)
  end

  # Unblocks the user.
  def unblock!
    self.update(blocked: false)
  end

  # Validates the user's account.
  def validate(token)
    if token == self.validation_token
      update(validation_token: nil, validated_at: DateTime.now)
    else
      return false
    end
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
        shows.reject! do |show|
          performance = show.performances.last
          unless performance.present?
            last_datetime = performance.start_at
            unless performance.repeat_until.present?
              date_difference = (performance.repeat_until - performance.start_at.to_date)
              last_datetime += date_difference
            end
            last_datetime < Time.now
          end
        end
        # Then authorise any such active shows that are not dormant.
        CamdramShow.where(camdram_id: shows.each(&:id), dormant: false, active: true)
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
        CamdramSociety.where(camdram_id: societies.each(&:id), active: true)
      rescue Roombooking::CamdramAPI::NoAccessToken => e
        raise e
      rescue
        raise Roombooking::CamdramAPI::CamdramError
      end
    end
  end

  # Either the user's email has been verified, in which case there should be no
  # token, or we are waiting for validation and the datetime field should be blank.
  def email_verification_state_must_be_valid
    if self.validated_at.nil? && self.validation_token.nil?
      errors.add(:validation_token, 'should be present if email is not validated.')
    end
    if self.validated_at.present? && self.validation_token.present?
      errors.add(:validation_token, 'should be blank if email is validated.')
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
