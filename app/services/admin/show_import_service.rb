# frozen_string_literal: true

module Admin
  class ShowImportService < ApplicationService
    def initialize(url)
      @url = url
    end

    def perform
      uri = URI(@url)
      path = uri.path.split('/')
      if path.length == 3 && path[1] == 'shows'
        slug = path[2]
        begin
          camdram_show = Roombooking::CamdramAPI.with { |client| client.get_show(slug) }
          roombooking_show = CamdramShow.create_from_camdram(camdram_show)
          roombooking_show.update(active: true)
          true
        rescue Exception
          false
        end
      else
        false
      end
    end
  end
end
