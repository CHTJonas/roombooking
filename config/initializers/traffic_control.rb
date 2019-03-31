# frozen_string_literal: true

ActiveJob::TrafficControl.client = ConnectionPool.new(size: 5, timeout: 5) {
  Redis.new(url: Rails.application.credentials.dig(:redis, :persistent_url))
}
