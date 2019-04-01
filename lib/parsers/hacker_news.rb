# frozen_string_literal: true

require 'htmlentities'

module Parsers
  class HackerNews < Base
    class << self
      def parse(raw_text)
        text = HTMLEntities.new.decode(raw_text)

        chunks = text.split('|')
        employer_name = AttributeStripper.strip_string(chunks[0], collapse_spaces: true, replace_newlines: true, allow_empty: true)

        words_count = employer_name.split(' ').count

        paragraphs = paragraphs(text)
        emails = parse_emails(paragraphs)
        urls = parse_urls(paragraphs)

        {
          employer_name: words_count.positive? && words_count < 5 ? employer_name : nil,
          paragraphs:    paragraphs,
          emails:        emails,
          urls:          urls,
          remoteness:    {
            onsite: onsite?(paragraphs),
            remote: remote?(paragraphs)
          },
          involvement:   {
            fulltime: fulltime?(paragraphs),
            parttime: parttime?(paragraphs)
          },
          technologies:  technologies(paragraphs)
        }
      end
    end
  end
end
