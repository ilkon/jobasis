# frozen_string_literal: true

Authonomy.configure do |config|
  config.secret_key      = Rails.application.credentials.secret_key_base
  config.stretches       = Rails.env.test? ? 1 : 11
  config.password_length = 8..64
end
