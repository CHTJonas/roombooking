# frozen_string_literal: true

module Roombooking
  module Markdown
    class << self
      def render(text)
        markdown_pool.with do |markdown|
          markdown.render(text).html_safe
        end
      end

      def render_without_wrap(text)
        wrapped_html = render(text)
        regex = Regexp.new(/\A<p>(.*)<\/p>(\n)*\z/m)
        match_data = regex.match(wrapped_html)
        match_data[1].html_safe
      end

      def render_like_camdram(text)
        str = Roombooking::Markdown::CamdramParser.parse(text)
        render(str)
      end

      private

      def markdown_pool
        @markdown_pool ||= ConnectionPool.new(size: ENV.fetch('RAILS_MAX_THREADS') { 5 }, timeout: 3) do
          Roombooking::Markdown::MarkdownFactory.new
        end
      end
    end
  end
end
