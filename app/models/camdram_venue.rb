# frozen_string_literal: true

# == Schema Information
#
# Table name: camdram_venues
#
#  id            :bigint           not null, primary key
#  camdram_id    :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  memoized_name :string
#

class CamdramVenue < ApplicationRecord
  include CamdramInteroperability

  has_paper_trail
  uses_camdram_client_method :get_venue

  has_and_belongs_to_many :rooms

  # Creates a CamdramVenue model from a numeric Camdram ID.
  def self.create_from_id(id)
    create_from_id_and_name(id, nil)
  end

  # Creates a CamdramVenue model from a numeric Camdram ID and name.
  def self.create_from_id_and_name(id, name)
    create! do |venue|
      venue.camdram_id = id
      venue.memoized_name = name if name.present?
    end
  end
end
