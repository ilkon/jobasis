# frozen_string_literal: true

class UserPassword < ApplicationRecord
  belongs_to :user, inverse_of: :user_password

  attr_accessor :password

  before_validation { self.password = password.strip if password.present? }

  validates :password, presence: true,
                       length:   { within: Authonomy.password_length },
                       format:   { with: Authonomy.password_regexp, message: I18n.t('auth.password.password_format') }

  before_save do
    self.encrypted_password = Authonomy::Encryptor.digest(password) if password.present?
  end

  def match?(password)
    Authonomy::Encryptor.compare(encrypted_password, password.try(:strip))
  end

  def set_reset_token
    token, encoded_token = Authonomy::TokenGenerator.generator.generate(self.class, :reset_token, Authonomy.reset_password_token_length)

    self.reset_token   = encoded_token
    self.reset_sent_at = Time.now.utc
    save(validate: false)
    token
  end

  def clear_reset_token
    self.reset_token   = nil
    self.reset_sent_at = nil
    save(validate: false)
  end

  class << self
    def find_by_reset_token(token)
      return nil unless token

      encoded_token = Authonomy::TokenGenerator.generator.digest(:reset_token, token)
      UserPassword.find_by(reset_token: encoded_token)
    end
  end
end
