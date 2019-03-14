# frozen_string_literal: true

camdram_log_file = Rails.root.join('log', "roombooking_#{Rails.env}_camdram.log")
Yell['camdram'] = Yell.new do |l|
  l.adapter(:datefile, camdram_log_file, keep: 5, level: 'gte.info')
end
