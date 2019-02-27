# frozen_string_literal: true

module Roombooking
  module Markdown
    class << self
      def render(text)
        markdown.render(text).html_safe
      end

      private

      def markdown
        markdown_pool.checkout
      end

      def markdown_pool
        @markdown_pool ||= ConnectionPool.new(size: ENV.fetch('RAILS_MAX_THREADS') { 5 }, timeout: 3) do
          # With the hashes in @options and @extensions we try to replicate
          # the style of the Camdram Markdown parser as closely as possible.
          @options ||= {
            filter_html: true,
            no_images: true,
            no_styles: true,
            safe_links_only: true,
            hard_wrap: true,
            link_attributes: { rel: 'nofollow', target: "_blank" }
          }
          @extensions ||= {
            no_intra_emphasis: true,
            fenced_code_blocks: true,
            autolink: true,
            strikethrough: true
          }
          @renderer ||= Redcarpet::Render::HTML.new(@options)
          markdown = Redcarpet::Markdown.new(@renderer, @extensions)
        end
      end
    end
  end
end
