# frozen_string_literal: true

if Rails.env.development?
  # Allows the iCal subscription URLs to be viewed in-browser rather than
  # triggering a download of the .ics file.
  Mime::Type.register "text/plain", :ics
end
