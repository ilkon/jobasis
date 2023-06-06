# frozen_string_literal: true

FactoryBot.define do
  factory :user_social_profile do
    association :user, strategy: :create

    provider_id { UserSocialProfile::PROVIDERS.values.sample }
    uid         { FFaker::String.from_regexp(/\w+\w+\w+\w+\w+\w+\w+\w+\w+\w+\w+/) }
  end
end
