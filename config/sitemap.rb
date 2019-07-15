# frozen_string_literal: true

SitemapGenerator::Sitemap.default_host = Roombooking::Host.url
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.create do
  Room.find_each do |room|
    add room_path(room), lastmod: room.updated_at, changefreq: 'hourly'
  end
  Booking.order('id DESC').limit(250).find_each do |booking|
    add booking_path(booking), lastmod: booking.updated_at, changefreq: 'daily'
  end
end
