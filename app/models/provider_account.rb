# frozen_string_literal: true

# == Schema Information
#
# Table name: provider_accounts
#
#  id         :bigint           not null, primary key
#  provider   :string           not null
#  uid        :string           not null
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProviderAccount < ApplicationRecord
  belongs_to :user
  validates_associated :user

  validates :provider, presence: true
  validates :uid, presence: true
end
