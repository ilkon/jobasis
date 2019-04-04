# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    association     :publisher, strategy: :build
    publisher_key   { FFaker::Guid.guid }
    published_at    { Time.now - 20.days - rand(10).days }
    last_fetched_at { Time.now - rand(10).days }
    date            { published_at.to_date }
  end
end
