# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]
Rails.application.config.filter_parameters += [:secret]
Rails.application.config.filter_parameters += [:api_key]
Rails.application.config.filter_parameters += [:credentials]
Rails.application.config.filter_parameters += [:token]
Rails.application.config.filter_parameters += [:refresh_token]
Rails.application.config.filter_parameters += [:bearer]
Rails.application.config.filter_parameters += ['rack.session']
