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
  has_and_belongs_to_many :rooms

  # Creates a CamdramVenue model from a numeric Camdram id.
  def self.create_from_id(id)
    create!(camdram_id: id)
  end

  # Returns the Camdram::Venue object that the record references by
  # querying the Camdram API.
  def camdram_object
    return nil unless self.camdram_id.present?
    @camdram_object ||= Roombooking::CamdramAPI.with do |client|
      client.get_venue(self.camdram_id).make_orphan
    end
  end
end
