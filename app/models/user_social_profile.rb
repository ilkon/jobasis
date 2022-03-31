# frozen_string_literal: true

class UserSocialProfile < ApplicationRecord
  PROVIDERS = {
    github: 1,
    google: 2
  }.freeze

  belongs_to :user, inverse_of: :user_social_profiles

  validates :provider_id, presence: true, inclusion: { in: PROVIDERS.values }
  validates :uid, presence: true, uniqueness: { scope: :provider_id }

  strip_attributes :uid
end
