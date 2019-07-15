# frozen_string_literal: true

keys = %w{ SECRET_KEY_BASE CAMDRAM_APP_ID CAMDRAM_APP_SECRET
  REDIS_CACHE REDIS_STORE SITE_HOSTNAME }
Dotenv.require_keys *keys
