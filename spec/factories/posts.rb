# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    publisher       { { strategy: :build } }
    publisher_key   { FFaker::Guid.guid }
    published_at    { 20.days.ago - rand(10).days }
    last_fetched_at { Time.zone.now - rand(10).days }
    date            { published_at.to_date }
  end
end
