# frozen_string_literal: true

module Parsers
  class Base
    class << self
      # Top-level domains
      def tld
        return @tld if @tld

        @tld = []
        filename = Rails.root.join('lib/parsers/dict/tlds-alpha-by-domain.txt').to_s
        File.readlines(filename).each do |line|
          next if line.start_with?('#')

          @tld << line.strip.downcase
        end

        @tld
      end

      def plain_emails(text)
        text.scan(/\b[^\s\;]+@\S+\.(?:#{tld.join('|')})\b/i)
      end

      def cryptic_emails(text)
        text.scan(/\b[\w\.\[\(\{\]\)\}\-+]+\s*(?:@|[\[\(\{]at[\]\)\}])\s*[\w\.\-]+\s*(?:\.|[\[\(\{]?\bdot\b[\]\)\}]?)\s*(?:#{tld.join('|')})\b/i)
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

      def skills(paragraphs)
        skills = {}

        mapped = {}
        Skill.find_each do |skill|
          mapped[skill.name] = skill
          skill.synonyms.each { |synonym| mapped[synonym] = skill }
        end

        names = mapped.keys.sort_by(&:length).reverse

        prgrphs = paragraphs.deep_dup

        names.each do |name|
          regexp = /(?<=\A|\W)#{name.gsub(/([\.\+\-\­\#\\])/, '\\\\\1')}(?=\W|\z)/i

          prgrphs.each do |prgrph|
            res = prgrph.gsub!(regexp, 'DUMMY')
            next unless res

            skill = mapped[name]
            skills[skill.id] = skill
          end
        end

        skills.values
      end

      def onsite?(paragraphs)
        paragraphs.any? { |p| p.match?(/\bon[\W_]*site\b/i) }
      end

      def remote?(paragraphs)
        paragraphs.any? { |p| p.match?(/\bremote\b/i) }
      end

      def fulltime?(paragraphs)
        paragraphs.any? { |p| p.match?(/\bfull[\W_]*time\b/i) }
      end

      def parttime?(paragraphs)
        paragraphs.any? { |p| p.match?(/\bpart[\W_]*time\b/i) }
      end

      def parse_emails(paragraphs)
        mapped = {}

        paragraphs.each do |paragraph|
          plain_emails(paragraph).each do |email|
            pure_email = email.downcase
            mapped[pure_email] ||= []
            mapped[pure_email] << email
          end

          cryptic_emails(paragraph).each do |email|
            pure_email = email.downcase.gsub(/[\[\(\{]?\bdot\b[\]\)\}]?/i, '.').gsub(/[\[\(\{]at[\]\)\}]/i, '@').delete(' ')
            mapped[pure_email] ||= []
            mapped[pure_email] << email
          end
        end

        pure_emails = mapped.keys.sort_by(&:length).reverse

        pure_emails.each_with_index do |pure_email, i|
          mapped[pure_email].each do |email|
            paragraphs.map! do |paragraph|
              paragraph.gsub(email, "###EMAIL#{i}###")
            end
          end
        end

        pure_emails
      end

      def parse_urls(paragraphs)
        mapped = {}

        paragraphs.each do |paragraph|
          schemed_urls(paragraph).each do |url|
            pure_url = url.downcase
            mapped[pure_url] ||= []
            mapped[pure_url] << url
          end
        end

        pure_urls = mapped.keys.sort_by(&:length).reverse

        pure_urls.each_with_index do |pure_url, i|
          mapped[pure_url].each do |url|
            paragraphs.map! do |paragraph|
              paragraph.gsub(url, "###URL#{i}###")
            end
          end
        end

        pure_urls
      end

      def text(paragraphs)
        sanitizer = Rails::Html::WhiteListSanitizer.new

        paragraphs.map do |paragraph|
          "<p>#{sanitizer.sanitize(paragraph, tags: %w[strong b em i small u a ul ol li], attributes: %w[href])}</p>"
        end.join
      end

      def parse(raw_text)
        text = raw_text.gsub(/&#x2F;/i, '/')

        paragraphs = paragraphs(text)

        employer_name = nil
        chunks = paragraphs.first.split('|')
        if chunks.count > 1
          employer_name = chunks.first.dup
          employer_name.gsub!(/[\[\(\{<].+[\]\)\}>]/, '')
          employer_name = AttributeStripper.strip_string(employer_name, collapse_spaces: true, replace_newlines: true, allow_empty: true)

          words_count = employer_name.split.count
          employer_name = nil if words_count >= 5 || words_count.zero?
        end

        emails = parse_emails(paragraphs)
        urls = parse_urls(paragraphs)

        {
          employer_name:,
          remoteness:    {
            onsite: onsite?(paragraphs),
            remote: remote?(paragraphs)
          },
          involvement:   {
            fulltime: fulltime?(paragraphs),
            parttime: parttime?(paragraphs)
          },
          skills:        skills(paragraphs),
          urls:,
          emails:,
          text:          text(paragraphs)
        }
      end
    end
  end
end
