# frozen_string_literal: true

require_relative 'concerns/typhoeus_requester'

module Fetchers
  class HackerNews
    include Fetchers::TyphoeusRequester

    API_URL = 'https://hacker-news.firebaseio.com/v0'

    class << self
      def fetch(publisher_key = '')
        publisher = Publisher.find_or_create_by!(name: name.demodulize)
        base_url = if publisher_key.blank?
                     "#{API_URL}/user/whoishiring.json"
                   else
                     "#{API_URL}/item/#{publisher_key}.json"
                   end

        key = { publisher_id: publisher.id, publisher_key: publisher_key }

        request_with(base_url) do |response|
          resp = JSON.parse(response.response_body, symbolize_names: true)
          published_at = Time.at(resp[:created] || resp[:time])

          case resp[:type]
          when 'comment'
            published_date = published_at.to_date
            data = {
              raw_text: resp[:text],
              author: resp[:by],
              published_at: published_at,
              last_fetched_at: Time.now,
              date: published_date
            }
            post_model_class = Post.partition_model(published_date)
            post_model_class.upsert(key, data)

          when 'story'
            if resp[:title]&.match?(/hiring\?/)
              data = {
                content: resp[:kids].to_json,
                published_at: published_at,
                last_fetched_at: Time.now
              }
              PublisherStash.upsert(key, data)
            end

          else
            data = {
              content: resp[:submitted].to_json,
              published_at: published_at,
              last_fetched_at: Time.now
            }
            PublisherStash.upsert(key, data)
          end
        end
      end
    end
  end
end
