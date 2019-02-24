class BatchImportJob < ApplicationJob
  def perform
    shows = ShowEnumerationService.perform
    shows.each do |camdram_show|
      begin
        CamdramShow.create_from_camdram(camdram_show).update(active: true)
      rescue ActiveRecord::RecordInvalid => e
        # Just skip over the show if it's not valid. most likely it's
        # already been imported before.
        next
      end
    end
  end
end
