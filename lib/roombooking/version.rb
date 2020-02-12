module Roombooking
  module Version
    class << self
      def release
        "Helium".freeze
      end

      def git_sha
        @version ||= `git rev-parse --short HEAD`.chomp.freeze
      end
    end
  end
end
