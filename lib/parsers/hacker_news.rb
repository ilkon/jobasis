# frozen_string_literal: true

require 'htmlentities'

module Parsers
  class HackerNews
    class << self
      def parse(raw_text)
        parsed = {}
        decoded_text = HTMLEntities.new.decode(raw_text)

        chunks = decoded_text.split('|')
        employer_name = AttributeStripper.strip_string(chunks[0], collapse_spaces: true, replace_newlines: true, allow_empty: true)

        words_count = employer_name.split(' ').count
        parsed[:employer_name] = employer_name if words_count.positive? && words_count < 5

        parsed
      end
    end
  end
end
