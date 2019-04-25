# frozen_string_literal: true

Peek.into Peek::Views::Git, nwo: 'CHTJonas/roombooking'
Peek.into Peek::Views::PerformanceBar
Peek.into Peek::Views::PG
Peek.into Peek::Views::Redis
Peek.into Peek::Views::Sidekiq
Peek.into Peek::Views::GC
Peek.into Peek::Views::Rblineprof

Rails.application.config.peek.adapter = :redis, {
  client: Redis.new(url: ENV['REDIS_CACHE']),
  expires_in: 60 * 30 # 30 minutes in seconds
}
