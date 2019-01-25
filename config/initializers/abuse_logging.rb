abuse_log_file = Rails.root.join('log', "roombooking_#{Rails.env}_abuse.log")
abuse_logger = Yell.new(format: '%d [ABUSE] %p : %m')
abuse_logger.adapter(:datefile, abuse_log_file, keep: 31)
Yell['abuse'] = abuse_logger
