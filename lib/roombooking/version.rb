module Roombooking
  module Version
    class << self
      def release
        'Argon'.freeze
      end

      def git_description
        @git_description ||= `git describe --tags --always --dirty`.chomp.freeze
      end

      def git_description_without_prefix
        git_description.delete_prefix('v').freeze
      end

      alias :to_s :git_description
    end
  end
end
