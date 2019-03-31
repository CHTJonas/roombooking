# frozen_string_literal: true

class NewTermJob < ApplicationJob
  concurrency 1, drop: true

  def perform
    CamdramShow.all.each do |show|
      show.update(dormant: true)
    end
  end
end
