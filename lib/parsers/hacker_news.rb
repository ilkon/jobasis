# frozen_string_literal: true

require 'htmlentities'

module Parsers
  class HackerNews
    class << self
      def tld
        return @tld if @tld

        @tld = []
        filename = Rails.root.join('lib', 'parsers', 'dict', 'tlds-alpha-by-domain.txt').to_s
        File.readlines(filename).each do |line|
          next if line.start_with?('#')

          @tld << line.strip.downcase
        end

        @tld = @tld.sort_by(&:length).reverse
      end

      def parse_emails(text)
        emails = text.scan(/[\w\d\.\-+_]+\s*@\s*[\w\d\.\-]+\s*(?:\.|\bdot\b)\s*(?:#{tld.join('|')})\b/i)

        mapped = {}
        emails.each do |email|
          pure_email = email.downcase.gsub(/\bdot\b/, '.').delete(' ')
          mapped[pure_email] ||= []
          mapped[pure_email] << email
        end

        pure_emails = mapped.keys.sort_by(&:length).reverse

        pure_emails.each_with_index do |pure_email, i|
          mapped[pure_email].each do |email|
            text.gsub!(email, "###EMAIL#{i}###")
          end
        end

        pure_emails
      end

      def parse_urls(text)
        urls = text.scan(%r{(?:(?:http[s]?:)?//)?[\w\d\.\-]+\.(?:#{tld.join('|')})[^\s<'",]+?\b}i)

        mapped = {}
        urls.each do |url|
          pure_url = url.downcase.gsub(/\bdot\b/, '.').delete(' ')
          mapped[pure_url] ||= []
          mapped[pure_url] << url
        end

        pure_urls = mapped.keys.sort_by(&:length).reverse

        pure_urls.each_with_index do |pure_url, i|
          mapped[pure_url].each do |url|
            text.gsub!(url, "###URL#{i}###")
          end
        end

        pure_urls
      end

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
        parsed[:emails] = emails
        parsed[:urls] = urls

        parsed
      end

      def syntax_units(text)
        _de_p_text = text.split(%r{<[\\]?p>|<br\s*[\/]?>}i).map(&:strip).select(&:present?)
        # de_p_text.map do |chunk|
        #   chunk.scan(/[^\.!?]+[\.!?]+|[^\.!?]+.\z/).map(&:strip)
        # end.flatten
      end
    end
  end
end
