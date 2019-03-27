# frozen_string_literal: true

module Parse
  class HackerNewsJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger = Logger.new(STDOUT)

      publisher = Publisher.find_by!(name: 'HackerNews')

      posts = Post.where('publisher_id = ? AND (last_parsed_at IS NULL OR last_parsed_at < last_fetched_at)', publisher.id)
      posts.each(&:parse!)
    end
  end
end
