# frozen_string_literal: true

require 'htmlentities'

module Parsers
  class HackerNews < Base
    class << self
      def parse(raw_text)
        parsed = {}
        text = HTMLEntities.new.decode(raw_text)

        chunks = text.split('|')
        employer_name = AttributeStripper.strip_string(chunks[0], collapse_spaces: true, replace_newlines: true, allow_empty: true)

        words_count = employer_name.split(' ').count
        parsed[:employer_name] = employer_name if words_count.positive? && words_count < 5

        emails = parse_emails(text)
        urls = parse_urls(text)

        parsed[:text] = text
        parsed[:paragraphs] = paragraphs(text)
        parsed[:emails] = emails
        parsed[:urls] = urls

        parsed
      end
    end
  end
end
