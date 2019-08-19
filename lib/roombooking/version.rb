# frozen_string_literal: true

module Roombooking
  Version = @version ||= `git rev-parse --short HEAD`.chomp.freeze
end
