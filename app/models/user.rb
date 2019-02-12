# frozen_string_literal: true

class User < ApplicationRecord
  has_many  :user_emails,           inverse_of: :user, dependent: :destroy
  has_one   :user_password,         inverse_of: :user, dependent: :destroy
  has_many  :user_social_profiles,  inverse_of: :user, dependent: :destroy
  has_one   :user_role,             inverse_of: :user, dependent: :destroy

  accepts_nested_attributes_for :user_password, :user_emails, :user_social_profiles, :user_role

  validates :name, presence: true, length: { in: 3..120, allow_blank: true }

  strip_attributes :name

  def password?(password)
    user_password&.match?(password)
  end

  class << self
    def find_by_email(email)
      pure_email = email.try(:strip).try(:downcase)

      includes(:user_role).joins(:user_emails).where(user_emails: { email: pure_email }).take
    end

    def find_by_social_profile(provider_id, uid)
      includes(:user_role).joins(:user_social_profiles).where(user_social_profiles: { provider_id: provider_id, uid: uid }).take
    end

    def find_by_access_token(user_id, issued_at)
      user = includes(:user_role).includes(:user_password).where(id: user_id).take

      return nil if user&.user_password && user.user_password.updated_at.to_i > issued_at

      user
    end
  end
end
