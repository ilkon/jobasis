# frozen_string_literal: true

module Parse
  class HackerNewsJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger = Logger.new(STDOUT)

      publisher = Publisher.find_by!(name: 'HackerNews')

      # posts = Post.where('publisher_id = ? AND (last_parsed_at IS NULL OR last_parsed_at < last_fetched_at)', publisher.id)
      posts = Post.where('publisher_id = ?', publisher.id)
      posts.each do |post|
        parsed = Parsers::HackerNews.parse(post.raw_text)

        # if parsed[:employer_name]
        #   employer = Employer.find_or_create_by!(name: parsed[:employer_name])
        #   post.employer_id = employer.id
        # end

        post.remoteness = 0
        Post::REMOTENESS.each_with_index do |f, i|
          post.remoteness |= (1 << i) if parsed.dig(:remoteness, f)
        end

        post.involvement = 0
        Post::INVOLVEMENT.each_with_index do |f, i|
          post.involvement |= (1 << i) if parsed.dig(:involvement, f)
        end

        post.technology_ids = parsed[:technologies].map(&:id)

        post.last_parsed_at = Time.now.utc
        post.save!
      end
    end
  end
end
