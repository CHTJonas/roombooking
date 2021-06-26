module Roombooking
  module Version
    class << self
      def release
        'Neon'.freeze
      end

      def git_description
        @git_description ||= `git describe --tags --always --dirty`.chomp.freeze
      end

      def git_description_without_prefix
        git_description.delete_prefix('v').freeze
      end
    end
  end
end
