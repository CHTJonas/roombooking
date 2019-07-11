# frozen_string_literal: true

# == Schema Information
#
# Table name: camdram_venues
#
#  id         :bigint           not null, primary key
#  camdram_id :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CamdramVenue < ApplicationRecord
  include CamdramInteroperability

  has_paper_trail
  uses_camdram_client_method :get_venue

  has_and_belongs_to_many :rooms

  # Creates a CamdramVenue model from a numeric Camdram id.
  def self.create_from_id(id)
    create!(camdram_id: id)
  end
end
