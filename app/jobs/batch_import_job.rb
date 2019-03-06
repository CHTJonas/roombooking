# frozen_string_literal: true

class BatchImportJob < ApplicationJob
  def perform(user_id)
    shows = ShowEnumerationService.perform
    shows.each do |camdram_show|
      begin
        cds = CamdramShow.create_from_camdram(camdram_show)
        cds.update(active: true)
        cds.block_out_bookings(User.find(user_id))
      rescue ActiveRecord::RecordInvalid => e
        # Just skip over the show if it's not valid. most likely it's
        # already been imported before.
        next
      end
    end
  end
end
