# frozen_string_literal: true

class Redis
  module DangerousCommands
    def flushdb
      raise NotImplementedError, 'This command is disabled - if you really want to truncate the entire database you should do it from `redis-cli`.'
    end

    def flushall
      raise NotImplementedError, 'This command is disabled - if you really want to truncate all databases you should do it from `redis-cli`.'
    end
  end

  # Disabled the `flushdb` and `flushall` commands in production.
  prepend DangerousCommands if Rails.env.production?
end
