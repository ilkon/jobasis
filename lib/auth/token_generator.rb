# frozen_string_literal: true

require 'openssl'

module Auth
  class TokenGenerator
    ALGO = 'SHA256'

    def initialize(key_generator)
      @key_generator = key_generator
    end

    def digest(column, token)
      key = key_for(column)
      token.present? && OpenSSL::HMAC.hexdigest(ALGO, key, token.to_s)
    end

    def generate(klass, column, length)
      key = key_for(column)

      loop do
        token = friendly_token(length)
        encoded_token = OpenSSL::HMAC.hexdigest(ALGO, key, token)
        break [token, encoded_token] unless klass.find_by(column => encoded_token)
      end
    end

    private

    def key_for(column)
      @key_generator.generate_key("Auth #{column}")
    end

    def friendly_token(length)
      rlength = (length * 3) / 4
      SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
    end
  end
end
