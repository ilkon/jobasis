# frozen_string_literal: true

require 'jwt'

module Auth
  module AuthenticatorFb
    ALGO = 'HS256'
    LEEWAY = 10.minutes

    class << self
      # Based on given token authenticates user or not
      def authenticate(token)
        segments = token.split('.')
        return nil unless segments.count == 2

        encoded_signature = segments.first
        encoded_payload   = segments.last

        ::JWT.verify_signature(ALGO, hmac_secret, encoded_payload, ::JWT::Decode.base64url_decode(encoded_signature))

        payload = ::JWT.decode_json(::JWT::Decode.base64url_decode(encoded_payload))

        raise JWT::InvalidIatError, 'Invalid issued_at' if !payload['issued_at'].is_a?(Numeric) || payload['issued_at'].to_i + LEEWAY < Time.now.utc.to_i

        payload['user_id']

      rescue ::JWT::DecodeError => e
        Rails.logger.debug "--- Auth: #{e}"
        nil
      end

      private

      def hmac_secret
        Rails.application.credentials.dig(:facebook_app_secret)
      end
    end
  end
end
