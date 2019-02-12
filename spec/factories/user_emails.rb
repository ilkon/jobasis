# frozen_string_literal: true

FactoryBot.define do
  factory :user_email do
    association :user, strategy: :create

    sequence(:email) { |n| "#{FFaker::Internet.user_name}#{n}@#{FFaker::Internet.domain_name}" }
  end

  factory :invalid_user_email, parent: :user_email do |f|
    f.email { 'just_a_string' }
  end
end
