# frozen_string_literal: true

FactoryBot.define do
  factory :publisher do
    sequence(:name) { |n| "#{FFaker::Company.name} #{n}" }
  end
end
