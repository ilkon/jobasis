# frozen_string_literal: true

module Parsers
  class Base
    class << self
      # Top-level domains
      def tld
        return @tld if @tld

        @tld = []
        filename = Rails.root.join('lib', 'parsers', 'dict', 'tlds-alpha-by-domain.txt').to_s
        File.readlines(filename).each do |line|
          next if line.start_with?('#')

          @tld << line.strip.downcase
        end

        @tld
      end

      def plain_emails(text)
        text.scan(/\b\S+@\S+\.(?:#{tld.join('|')})\b/i)
      end

      def cryptic_emails(text)
        text.scan(/\b[\w\.\-+]+\s*(?:@|[\[\(\{]at[\]\)\}])\s*[\w\.\-]+\s*(?:\.|\bdot\b)\s*(?:#{tld.join('|')})\b/i)
      end

      def domains(text)
        text.scan(/\b[\w\.\-]+\.(?:#{tld.join('|')})\b/i)
      end

      def schemed_urls(text)
        text.scan(%r{\b(?:http[s]?:)?//[\w\.\-]+\.(?:#{tld.join('|')})[\#/\?]?[\w\.\-\+\=\!\#\/\?\&]*}i)
      end

      def paragraphs(text)
        text.split(%r{<[\\]?\s*p\s*[\/]?>|<br\s*[\/]?>}i).map do |p|
          AttributeStripper.strip_string(p, collapse_spaces: true, replace_newlines: true, allow_empty: true)
        end.select(&:present?)
      end

      def onsite?(paragraphs)
        paragraphs.any? { |p| p.match?(/\bon[\s\-]*site\b/i) }
      end

      def remote?(paragraphs)
        paragraphs.any? { |p| p.match?(/\bremote\b/i) }
      end

      def fulltime?(paragraphs)
        paragraphs.any? { |p| p.match?(/\bfull[\s\-]*time\b/i) }
      end

      def parttime?(paragraphs)
        paragraphs.any? { |p| p.match?(/\bpart[\s\-]*time\b/i) }
      end

      def parse_emails(text)
        mapped = {}

        plain_emails(text).each do |email|
          pure_email = email.downcase
          mapped[pure_email] ||= []
          mapped[pure_email] << email
        end

        cryptic_emails(text).each do |email|
          pure_email = email.downcase.gsub(/\bdot\b/i, '.').gsub(/[\[\(\{]at[\]\)\}]/i, '@').delete(' ')
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
        mapped = {}

        schemed_urls(text).each do |url|
          pure_url = url.downcase
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
    end
  end
end
