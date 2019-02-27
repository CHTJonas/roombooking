# frozen_string_literal: true

Maildown::MarkdownEngine.set_html do |text|
  carpet = Redcarpet::Markdown.new(Redcarpet::Render::HTML, {})
  carpet.render(text).html_safe
end

Maildown.allow_indentation = true
