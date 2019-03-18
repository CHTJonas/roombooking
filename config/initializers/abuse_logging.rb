# frozen_string_literal: true

abuse_log_file = Rails.root.join('log', "roombooking_#{Rails.env}_abuse.log")
Yell['abuse'] = Yell.new(format: '%d [ABUSE] %p : %m') do |l|
  l.adapter(:datefile, abuse_log_file, keep: 31)
end
