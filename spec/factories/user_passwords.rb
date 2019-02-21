# frozen_string_literal: true

FactoryBot.define do
  factory :user_password do
    association :user, strategy: :create

    password { FFaker::String.from_regexp(/\w{12}[a-z][A-Z]\d/) }
  end
end
