# frozen_string_literal: true

FactoryBot.define do
  factory :user_password do
    association :user, strategy: :create

    password { "#{FFaker::String.from_regexp(/[a-z]{5}[A-Z]{5}\d{3}[@$%#?!^&*-]{3}/)}\#$@" }
  end
end
