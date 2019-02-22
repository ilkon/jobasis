# frozen_string_literal: true

require 'auth'

Auth.configure do |config|
  config.stretches = Rails.env.test? ? 1 : 11

  config.password_length = 8..64
  config.confirm_email_token_length = 48
  config.reset_password_token_length = 48
end
