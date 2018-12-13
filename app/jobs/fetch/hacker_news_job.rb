# frozen_string_literal: true

module Fetch
  class HackerNewsJob < ApplicationJob
    MAX_AGE_FOR_STASH = 4.months

    queue_as :default

    def perform
      Rails.logger = Logger.new(STDOUT)

      today = Date.today
      publisher = Publisher.find_or_create_by!(name: 'HackerNews')

      stashes = PublisherStash.where(publisher_id: publisher.id).index_by(&:publisher_key)
      post_publisher_keys = Post.where(publisher_id: publisher.id).pluck(:publisher_key)

      pool = stashes.keys.map { |publisher_key| [publisher_key, 'story'] }.to_h
      pool[Fetchers::HackerNews::ROOT_PUBLISHER_KEY] = nil

      loop do
        break if pool.empty?

        publisher_key = pool.first.first
        type = pool.delete(publisher_key)

        next if post_publisher_keys.include?(publisher_key)

        stash = stashes[publisher_key]
        if stash
          if publisher_key == Fetchers::HackerNews::ROOT_PUBLISHER_KEY
            next if today.day > 7
          elsif stash.published_at
            next if stash.published_at < today - MAX_AGE_FOR_STASH

            published_ago = today - stash.published_at.to_date
            last_fetched_ago = today - stash.last_fetched_at.to_date
            next if published_ago.to_i / 30 > last_fetched_ago.to_i
          end
        end

        response = Fetchers::HackerNews.fetch(publisher_key)
        next unless response && response[:type] == type

        key = { publisher_id: publisher.id, publisher_key: publisher_key }

        case response[:type]
        when 'comment'
          next unless response[:time] && response[:text]

          published_at = Time.at(response[:time])
          published_date = published_at.to_date
          data = {
            raw_text:        response[:text],
            author:          response[:by],
            published_at:    published_at,
            last_fetched_at: Time.now,
            date:            published_date
          }
          Post.partition_model(published_date).create(key.merge(data))

        when 'story'
          next unless response[:time] && response[:kids].present? && response[:title]&.match?(/Ask HN: Who is hiring\?/)

          published_at = Time.at(response[:time])
          next if published_at < today - MAX_AGE_FOR_STASH

          data = {
            content:         response[:kids].to_json,
            published_at:    published_at,
            last_fetched_at: Time.now
          }
          stash ? stash.update(data) : PublisherStash.create(key.merge(data))

          (response[:kids] || []).each { |child| pool[child.to_s] = 'comment' }

        else
          next unless response[:created] && response[:submitted].present?

          published_at = Time.at(response[:created])
          data = {
            content:         response[:submitted].to_json,
            published_at:    published_at,
            last_fetched_at: Time.now
          }
          stash ? stash.update(data) : PublisherStash.create(key.merge(data))

          (response[:submitted] || []).each { |child| pool[child.to_s] = 'story' }
        end
      end
    end
  end
end