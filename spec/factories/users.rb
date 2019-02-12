# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { FFaker::Name.name }
  end

  factory :invalid_user, parent: :user do |f|
    f.name nil
  end
end
