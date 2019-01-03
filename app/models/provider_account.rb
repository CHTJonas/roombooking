class ProviderAccount < ApplicationRecord
  belongs_to :user
  validates_associated :user

  validates :provider, presence: true
  validates :uid, presence: true
end
