# frozen_string_literal: true

require 'typhoeus'

module Auth
  module Api
    module Github
      AUTHORIZE_URL = 'https://github.com/login/oauth/authorize'
      TOKEN_URL     = 'https://github.com/login/oauth/access_token'
      USERINFO_URL  = 'https://api.github.com/user'

      class << self
        def authorize_url(state)
          query_values = {
            client_id: Rails.application.credentials.dig(:auth, :github, :client_id),
            state:     state
          }

          AUTHORIZE_URL + '?' + query_values.to_query
        end

        def access_token(code, state)
          return nil unless code && state

          options = {
            params:  {
              client_id:     Rails.application.credentials.dig(:auth, :github, :client_id),
              client_secret: Rails.application.credentials.dig(:auth, :github, :client_secret),
              code:          code,
              state:         state
            },
            headers: {
              Accept: 'application/json'
            }
          }
          response = Typhoeus.post(TOKEN_URL, options)

          if response.success?
            resp = JSON.parse(response.response_body, symbolize_names: true)

            return resp[:access_token] if resp.is_a?(Hash) && resp[:access_token]
          end

          nil
        end

        def userinfo(access_token)
          return nil unless access_token

          options = {
            headers: {
              Authorization: "token #{access_token}"
            }
          }
          response = Typhoeus.get(USERINFO_URL, options)

          return JSON.parse(response.response_body, symbolize_names: true) if response.success?

          nil
        end
      end
    end
  end
end
