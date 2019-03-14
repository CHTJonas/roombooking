# Don't freeze string with magic comment.
# See: https://github.com/rudionrails/yell/issues/50

abuse_log_file = Rails.root.join('log'.freeze, "roombooking_#{Rails.env}_abuse.log")
Yell['abuse'.freeze] = Yell.new(format: '%d [ABUSE] %p : %m') do |l|
  l.adapter(:datefile, abuse_log_file, keep: 31)
end
