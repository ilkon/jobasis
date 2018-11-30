# frozen_string_literal: true

require 'typhoeus'

module Fetchers
  module TyphoeusRequester
    def self.included(base)
      base.class_eval do
        def self.request_with(base_url, options = {})
          request = Typhoeus::Request.new(base_url, options)

          # Config.logger.info "#{name.demodulize}: requesting #{request.url}"

          request.on_complete do |response|
            if response.success?
              yield(response)
              # elsif response.timed_out?
              #   # Config.logger.error "#{name.demodulize}: fetching timed out, interrupting"
              # elsif response.code.zero?
              #   # Config.logger.error "#{name.demodulize}: fetching #{response.return_message}"
              # else
              #   # Config.logger.error "#{name.demodulize}: fetching failed with code #{response.code}"
            end
          end

          request.run
        end
      end
    end
  end
end
