# frozen_string_literal: true

module Roombooking
  module Markdown
    module MarkdownFactory
      class << self
        def new
          Redcarpet::Markdown.new(renderer, extensions)
        end

        private

        def renderer
          @renderer ||= Redcarpet::Render::HTML.new(options)
        end

        def options
          @options ||= {
            filter_html: true,
            no_images: true,
            no_styles: true,
            safe_links_only: true,
            hard_wrap: true,
            link_attributes: { rel: 'nofollow', target: "_blank" }
          }
        end

        def extensions
          @extensions ||= {
            no_intra_emphasis: true,
            fenced_code_blocks: true,
            autolink: true,
            strikethrough: true
          }
        end
      end
    end
  end
end
