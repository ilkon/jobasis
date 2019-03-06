# frozen_string_literal: true

module Auth
  class << self
    WRITER_METHODS = %i[
      pepper
      stretches
      password_length
      regular_session_ttl
      memorized_session_ttl
      password_check_session_ttl
      auth_provider_check_session_ttl
      confirm_email_token_ttl
      confirm_email_token_length
      reset_password_token_ttl
      reset_password_token_length
      oauth_state_token_length
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

    def password_regexp
      /\A
        (?=.*\d)           # Must contain a digit
        (?=.*[a-z])        # Must contain a lowercase character
        (?=.*[A-Z])        # Must contain an uppercase character
      /x
    end

    def token_generator
      @token_generator ||= Auth::TokenGenerator.new(
        ActiveSupport::CachingKeyGenerator.new(
          ActiveSupport::KeyGenerator.new(Rails.application.credentials.dig(:secret_key_base))
        )
      )
    end

    def password_length
      @password_length || (8..64)
    end

    def regular_session_ttl
      @regular_session_ttl || 30.minutes
    end

    def memorized_session_ttl
      @memorized_session_ttl || 90.days
    end

    def password_check_session_ttl
      @password_check_session_ttl || 5.minutes
    end

    def auth_provider_check_session_ttl
      @auth_provider_check_session_ttl || 5.minutes
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

    def oauth_state_token_length
      @oauth_state_token_length || 24
    end
  end
end
