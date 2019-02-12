# frozen_string_literal: true

module Auth
  class << self
    WRITER_METHODS = %i[
      pepper
      stretches
      password_length
      access_token_ttl
      refresh_token_ttl
      confirm_email_token_ttl
      confirm_email_token_length
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

    def email_regexp
      /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
    end

    def token_generator
      @token_generator ||= Auth::TokenGenerator.new(
        ActiveSupport::CachingKeyGenerator.new(
          ActiveSupport::KeyGenerator.new(Rails.application.credentials.dig(:secret_key_base))
        )
      )
    end

    def password_length
      @password_length || (6..64)
    end

    def access_token_ttl
      @access_token_ttl || 15.minutes
    end

    def refresh_token_ttl
      @refresh_token_ttl || 1.week
    end

    def confirm_email_token_ttl
      @confirm_email_token_ttl || 48.hours
    end

    def confirm_email_token_length
      @confirm_email_token_length || 48
    end

    def reset_password_token_ttl
      @reset_password_token_ttl || 15.minutes
    end

    def reset_password_token_length
      @reset_password_token_length || 48
    end

    def cookie_name
      '_auth_token'
    end
  end
end
