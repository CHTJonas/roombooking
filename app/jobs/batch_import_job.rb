class BatchImportJob < ApplicationJob
  def perform
    shows = ShowEnumerationService.perform
    shows.each do |camdram_show|
      roombooking_show = CamdramShow.create_from_camdram(camdram_show)
      roombooking_show.update(active: true)
    end
  end
end
