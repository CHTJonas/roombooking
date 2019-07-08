# frozen_string_literal: true

# Asset master version - change this to expire all assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'mailers')

# Precompile additional assets.
Rails.application.config.assets.precompile += %w( mail.css )
