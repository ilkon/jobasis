# frozen_string_literal: true

require 'uri/mailto'

module Attributor
  class << self
    WRITER_METHODS = %i[
      pepper
      stretches
      password_length
      refresh_token_ttl
      reset_password_token_ttl
      reset_password_token_length
    ].freeze
    attr_writer(*WRITER_METHODS)

    READER_METHODS = %i[
      pepper
    ].freeze
    attr_reader(*READER_METHODS)

    def configure
      yield self if block_given?
    end

    def stretches
      @stretches || 11
    end

    def password_regexp
      %r{
        \A
        (?=.*\d)                                      # Must contain a digit
        (?=.*[a-z])                                   # Must contain a lowercase character
        (?=.*[A-Z])                                   # Must contain an uppercase character
        (?=.*[!"#$%&'()*+,\-./:;<=>?@\[\\\]^_`{|}~])  # Must contain a special character
      }x
    end

    def password_length
      @password_length || (8..64)
    end

    def email_regexp
      # /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
      URI::MailTo::EMAIL_REGEXP
    end

    def refresh_token_ttl
      @refresh_token_ttl || 1.week
    end

    def reset_password_token_ttl
      @reset_password_token_ttl || 60.minutes
    end

    def reset_password_token_length
      @reset_password_token_length || 48
    end
  end
end
