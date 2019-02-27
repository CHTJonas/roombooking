# frozen_string_literal: true

module Admin
  class SocietyRetrievalService < ApplicationService
    def perform
      camdram_societies = Roombooking::CamdramAPI.with { |client| client.get_societies.sort_by(&:name) }
      society_tuples = Array.new(camdram_societies.length)
      camdram_societies.each_with_index do |camdram_society, i|
        roombooking_society = CamdramSociety.find_from_camdram(camdram_society)
        society_tuples[i] = [camdram_society, roombooking_society]
      end
      society_tuples
    end
  end
end
