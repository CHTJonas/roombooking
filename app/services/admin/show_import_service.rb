# frozen_string_literal: true

module Admin
  class ShowImportService < ApplicationService
    def initialize(url, user)
      @url = url
      @user = user
    end

    def perform
      uri = URI(@url)
      path = uri.path.split('/')
      if path.length == 3 && path[1] == 'shows'
        slug = path[2]
        begin
          camdram_show = Roombooking::CamdramAPI.with { |client| client.get_show(slug) }
          CamdramShow.create_from_camdram(camdram_show).block_out_bookings(@user)
          true
        rescue Exception => e
          false
        end
      else
        false
      end
    end
  end
end
