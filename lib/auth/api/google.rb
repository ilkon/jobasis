# frozen_string_literal: true

require 'typhoeus'

module Auth
  module Api
    module Google
      AUTHORIZE_URL = 'https://accounts.google.com/o/oauth2/v2/auth'
      TOKEN_URL     = 'https://www.googleapis.com/oauth2/v4/token'
      USERINFO_URL  = 'https://www.googleapis.com/oauth2/v3/userinfo'

      class << self
        def authorize_url(state, redirect_uri)
          query_values = {
            client_id:     Rails.application.credentials.dig(:auth, :google, :client_id),
            redirect_uri:  redirect_uri,
            scope:         'profile email',
            response_type: 'code',
            state:         state
          }

          "#{AUTHORIZE_URL}?#{query_values.to_query}"
        end

        def access_token(code, redirect_uri)
          return nil unless code && redirect_uri

          options = {
            params: {
              client_id:     Rails.application.credentials.dig(:auth, :google, :client_id),
              client_secret: Rails.application.credentials.dig(:auth, :google, :client_secret),
              redirect_uri:  redirect_uri,
              code:          code,
              grant_type:    'authorization_code'
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
              Authorization: "Bearer #{access_token}"
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
