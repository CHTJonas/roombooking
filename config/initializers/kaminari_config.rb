# frozen_string_literal: true

Kaminari.configure do |config|
  config.default_per_page = 10
  config.max_per_page = nil
  config.window = 4
  config.outer_window = 0
  config.params_on_first_page = true
end
