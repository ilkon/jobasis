# frozen_string_literal: true

require_relative 'concerns/typhoeus_requester'

module Fetchers
  class HackerNews
    include Fetchers::TyphoeusRequester

    API_URL = 'https://hacker-news.firebaseio.com/v0'
    ROOT_PUBLISHER_KEY = '0'

    class << self
      def fetch(publisher_key)
        base_url = if publisher_key == ROOT_PUBLISHER_KEY
                     "#{API_URL}/user/whoishiring.json"
                   else
                     "#{API_URL}/item/#{publisher_key}.json"
                   end

        request_with(base_url) do |response|
          JSON.parse(response.response_body, symbolize_names: true)
        end
      end

      def save(publisher_id, publisher_key, resp)
        key = { publisher_id: publisher_id, publisher_key: publisher_key }

        case resp[:type]
        when 'comment'
          return unless resp[:time] && resp[:text]

          published_at = Time.at(resp[:time])
          published_date = published_at.to_date
          data = {
            raw_text:        resp[:text],
            author:          resp[:by],
            published_at:    published_at,
            last_fetched_at: Time.now,
            date:            published_date
          }
          post_model_class = Post.partition_model(published_date)
          post_model_class.upsert(key, data)

        when 'story'
          return unless resp[:time] && resp[:kids].present?
          return unless resp[:title]&.match?(/Ask HN: Who is hiring\?/)

          published_at = Time.at(resp[:time])
          data = {
            content:         resp[:kids].to_json,
            published_at:    published_at,
            last_fetched_at: Time.now
          }
          PublisherStash.upsert(key, data)

        else
          return unless resp[:created] && resp[:submitted].present?

          published_at = Time.at(resp[:created])
          data = {
            content:         resp[:submitted].to_json,
            published_at:    published_at,
            last_fetched_at: Time.now
          }
          PublisherStash.upsert(key, data)
        end
      end
    end
  end
end
