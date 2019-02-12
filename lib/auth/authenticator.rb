# frozen_string_literal: true

require 'jwt'

module Auth
  module Authenticator
    ALGO = 'HS256'
    LEEWAY = 30.seconds

    class << self
      # Returns access_token and refresh_token for user authentication
      def tokens(user, refresh_exp = nil)
        now = Time.now.utc.to_i
        payload = {
          sub:  user.id,
          iat:  now,
          exp:  now + Auth.access_token_ttl.to_i,
          name: user.name
        }.tap do |p|
          p[:admin] = true if user.user_role.try(:admin)
        end
        digest = payload_digest(payload)

        refresh_payload = {
          acc: digest
        }
        if refresh_exp
          refresh_payload[:exp] = if refresh_exp.is_a?(Integer)
                                    refresh_exp
                                  else
                                    now + Auth.refresh_token_ttl.to_i
                                  end
        end

        cookie_payload = {
          dig: digest,
          iat: now
        }

        [encode(payload), encode(refresh_payload), encode(cookie_payload)]
      end

      # Based on given access and refresh tokens authenticates user or not
      def authenticate(access_token, refresh_token, cookie)
        valid_tokens = true
        generate_response_tokens = false
        refresh_exp = nil
        payload = nil

        if valid_tokens
          access_opts = {
            verify_sub:        true,
            verify_iat:        true,
            verify_expiration: true
          }

          if refresh_token
            refresh_payload = decode(refresh_token, verify_expiration: false)
            refresh_exp = refresh_payload['exp']

            if refresh_exp && refresh_exp > Time.now.utc.to_i
              # don't verify access token expiration if refresh token has an exp timestamp and not expired yet
              access_opts[:verify_expiration] = false
            else
              # sliding expiration
              refresh_exp = nil
            end

            payload = decode(access_token, access_opts)

            valid_tokens = (refresh_payload['acc'] == payload_digest(payload))

            Rails.logger.debug '--- Auth: Refresh token mismatch' unless valid_tokens

            # to avoid tokens/cookies mismatch for multiple simultaneous calls
            age = Time.now.utc.to_i - payload['iat']
            generate_response_tokens = true if age > 60

          else
            payload = decode(access_token, access_opts)

            valid_tokens = true
          end
        end

        if valid_tokens
          # Due to optimistic rendering of Admin-on-REST frontend, sometimes request can contain
          # fresh cookie but old token. It needs to be processed correctly
          if cookie
            cookie_payload = decode(cookie, verify_expiration: false)
            cookie_iat = cookie_payload['iat']
            valid_tokens = cookie_iat &&
                           (cookie_payload['dig'] == payload_digest(payload.merge(iat: cookie_iat, exp: cookie_iat + Auth.access_token_ttl))) &&
                           (cookie_iat - payload['iat'] >= 0 && cookie_iat - payload['iat'] < Auth.access_token_ttl)

            Rails.logger.debug '--- Auth: Cookie mismatch' unless valid_tokens
          else
            valid_tokens = false

            Rails.logger.debug '--- Auth: Cookie is absent' unless valid_tokens
          end
        end

        return nil unless valid_tokens

        user = User.find_by_access_token(payload['sub'], payload['iat'])
        if user && generate_response_tokens
          [user] + tokens(user, refresh_exp)
        else
          user
        end

      rescue ::JWT::DecodeError => e
        Rails.logger.debug "--- Auth: #{e}"
        nil
      end

      private

      def encode(payload)
        ::JWT.encode(payload, hmac_secret, ALGO)
      end

      def decode(token, opts = {})
        ::JWT.decode(token, hmac_secret, true, opts.merge(leeway: LEEWAY, algorithm: ALGO)).first
        # can throw JWT::IncorrectAlgorithm, JWT::VerificationError, JWT::ExpiredSignature, JWT::InvalidIatError, JWT::InvalidSubError
      end

      def payload_digest(payload)
        Digest::MD5.hexdigest(payload.to_json)
      end

      def hmac_secret
        Rails.application.credentials.dig(:json_web_token_secret)
      end
    end
  end
end
