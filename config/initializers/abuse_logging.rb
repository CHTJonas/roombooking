# Don't freeze string with magic comment.
# See: https://github.com/rudionrails/yell/issues/50

abuse_log_file = Rails.root.join('log'.freeze, "roombooking_#{Rails.env}_abuse.log")
abuse_logger = Yell.new(format: '%d [ABUSE] %p : %m')
abuse_logger.adapter(:datefile, abuse_log_file, keep: 31)
Yell['abuse'.freeze] = abuse_logger
