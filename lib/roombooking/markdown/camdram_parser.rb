# frozen_string_literal: true

module Roombooking
  module Markdown
    module CamdramParser
      class << self
        def parse(text)
          str = scrub(text)
          regex.each do |pattern, replacement|
            str.gsub!(pattern, replacement)
          end
          str
        end

        private

        def scrub(text)
          html_fragment = Loofah.fragment(text)
          html_fragment.scrub!(scrubber)
          html_fragment.to_s
        end

        def scrubber
          @scrubber ||= (
            tags = ['b', 'i', 'u', 'strong', 'em', 'p', 'ul', 'li', 'ol', 'br', 'green', 'red', 'pre', 'hr']
            s = Rails::Html::TargetScrubber.new
            s.tags = tags
            s
          )
        end

        def regex
          # https://camdram.github.io/api/markdown
          @regex ||= {
            /\[L:(www\.[a-zA-Z0-9\.:\\\/\_\-\?\&]+)\]/          => '[\\1](http://\\1)',
            /\[L:([a-zA-Z0-9\.:\\\/\_\-\?\&]+)\]/               => '\\1',
            /\[L:(www\.[a-zA-Z0-9\.:\\\/\_\-\?\&]+);([^\]]+)\]/ => '[\\2](http://\\1)',
            /\[L:([a-zA-Z0-9\.:\\\/\_\-\?\&]+);([^\]]+)\]/      => '[\\2](\\1)',
            /\[E:([a-zA-Z0-9\.@\_\-]+)\]/                      => '[\\1](mailto:\\1)',
            /\[E:([a-zA-Z0-9\.@\_\-]+);([^\]]+)\]/             => '[\\2](mailto:\\1)',
            /\[L:mailto\:([a-zA-Z0-9\.@\_\-]+)\]/              => '[\\1](mailto:\\1)',
            /\[L:mailto\:([a-zA-Z0-9\.@\_\-]+);([^\]]+)\]/     => '[\\2](mailto:\\1)',
            /<\/?b>/                                           => '**',
            /<\/?i>/                                           => '*',
            /<br ?\/?>/                                        => "\n",
            /<hr ?\/?>/                                        => "\n_______\n",
            /(?m)^(\#{2,5}[^#])/                                => "#\\1",
            /(?m)^#([^#])/                                     => "###\\1",
          }
        end
      end
    end
  end
end
