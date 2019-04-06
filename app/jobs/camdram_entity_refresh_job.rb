# frozen_string_literal: true

class CamdramEntityRefreshJob < ApplicationJob
  concurrency 1, drop: true

  def perform(*args)
    CamdramShow.find_each(batch_size: 10) { |e| refresh.call(e) }
    CamdramSociety.find_each(batch_size: 10) { |e| refresh.call(e) }
  end

  def refresh
    @refresh ||= Proc.new do |camdram_entity|
      puts camdram_entity.name(true)
      sleep 1 # Avoid hitting Camdram with requests too hard.
    end
  end
end
