# frozen_string_literal: true

# https://github.com/HackerNews/API

module Fetch
  class HackerNewsJob < ApplicationJob
    MAX_AGE_FOR_POST = 4.months

    queue_as :fetchers

    def perform
      today = Time.zone.today
      publisher = Publisher.find_or_create_by!(name: 'HackerNews')

      posts = Post.where(publisher_id: publisher.id)
      indexed_posts = posts.index_by(&:publisher_key)

      processing_pool = {}
      posts.each do |post|
        processing_pool[post.publisher_key] = post.vacancy ? :comment : :story
      end
      processing_pool[Fetchers::HackerNews::ROOT_PUBLISHER_KEY] = :user

      loop do
        break if processing_pool.empty?

        publisher_key = processing_pool.first.first
        type = processing_pool.delete(publisher_key)

        post = indexed_posts[publisher_key]
        if post
          if type == :user
            next if today.day > 7
          else
            next if post.published_at < today - MAX_AGE_FOR_POST

            published_ago = today - post.published_at.to_date
            last_fetched_ago = today - post.last_fetched_at.to_date
            next if published_ago.to_i / 30 > last_fetched_ago.to_i
          end
        end

        response = Fetchers::HackerNews.fetch(publisher_key)
        next unless response && (response[:type] || 'user') == type.to_s

        key = { publisher_id: publisher.id, publisher_key: publisher_key }

        published_time = response[:time] || response[:created]
        next unless published_time

        published_at = Time.zone.at(published_time)
        published_date = published_at.to_date

        data = {
          published_at: published_at,
          author:       response[:by],
          date:         published_date
        }

        case type
        when :user
          next if response[:submitted].blank?

          data[:author] = response[:id]

          (response[:submitted] || []).each { |child| processing_pool[child.to_s] = :story }

        when :story
          next unless response[:kids].present? && response[:title]&.match?(/Ask HN: Who is hiring\?/)

          next if published_date < today - MAX_AGE_FOR_POST

          (response[:kids] || []).each { |child| processing_pool[child.to_s] = :comment }

        when :comment
          next unless response[:text]

          data[:text] = response[:text]
          data[:vacancy] = true
        end

        if post
          if data.any? { |k, v| post[k] != v }
            data[:last_fetched_at] = Time.now.utc
            post.update(data)
            Parse::BaseJob.perform_later(post)
          end
        else
          data[:last_fetched_at] = Time.now.utc
          post = Post.partition_model(published_date).create(key.merge(data))
          Parse::BaseJob.perform_later(post)
        end
      end
    end
  end
end
