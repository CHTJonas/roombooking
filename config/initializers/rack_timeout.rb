# frozen_string_literal: true

log_file = Rails.root.join('log', "roombooking_#{Rails.env}_timeout.log")
Yell['rack_timeout'] = Yell.new do |l|
  l.adapter(:datefile, log_file, keep: 31, level: 'gte.info')
end
Rack::Timeout::Logger.logger = Yell['rack_timeout']
