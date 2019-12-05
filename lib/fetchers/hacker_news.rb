# frozen_string_literal: true

require_relative 'concerns/typhoeus_requester'

module Fetchers
  class HackerNews
    include Fetchers::Concerns::TyphoeusRequester

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
    end
  end
end
