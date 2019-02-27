# frozen_string_literal: true

camdram_log_file = Rails.root.join('log', "roombooking_#{Rails.env}_camdram.log")
camdram_logger = Yell.new
camdram_logger.adapter(:datefile, camdram_log_file, keep: 5, level: 'gte.info')
Yell['camdram'] = camdram_logger
