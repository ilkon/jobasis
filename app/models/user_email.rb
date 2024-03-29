# frozen_string_literal: true

class UserEmail < ApplicationRecord
  belongs_to :user, inverse_of: :user_emails

  before_validation { email.downcase! if email.present? }
  before_destroy { throw(:abort) if confirmed_at }

  validates :email, presence: true, uniqueness: true, format: { with: Authonomy.email_regexp }

  strip_attributes :email

  def set_confirm_token
    token, encoded_token = Authonomy::TokenGenerator.generator.generate(self.class, :confirm_token, Authonomy.confirm_email_token_length)

    self.confirm_token    = encoded_token
    self.confirm_sent_at  = Time.now.utc
    save(validate: false)
    token
  end

  def clear_confirm_token
    self.confirm_token    = nil
    self.confirm_sent_at  = nil
    self.confirmed_at     = Time.now.utc
    save(validate: false)
  end

  class << self
    def find_by_confirm_token(token)
      return nil unless token

      encoded_token = Authonomy::TokenGenerator.generator.digest(:confirm_token, token)
      UserEmail.find_by(confirm_token: encoded_token)
    end
  end
end
