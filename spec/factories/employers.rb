# frozen_string_literal: true

FactoryBot.define do
  factory :employer do
    sequence(:name) { |n| "#{FFaker::Company.name} #{n}" }
    url { FFaker::Internet.http_url }
  end
end
