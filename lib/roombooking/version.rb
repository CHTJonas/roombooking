module Roombooking
  module Version
    class << self
      def to_s
        @version ||= `git rev-parse --short HEAD`.chomp.freeze
      end
    end
  end
end
