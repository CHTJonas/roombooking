module Roombooking
  module Version
    class << self
      def release
        "Neon".freeze
      end

      def git_description
        @git_description ||= (`git describe --tags 2>/dev/null || git rev-parse --short HEAD`.chomp + `[[ -z $(git status -s) ]] || echo ' dirty'`.chomp).freeze
      end
    end
  end
end
