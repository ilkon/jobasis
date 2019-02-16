# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    association     :publisher, strategy: :build
    association     :employer, strategy: :build
    publisher_key   { FFaker::Guid.guid }
    published_at    { Time.now.utc - 5.days - rand(5).days }
    last_fetched_at { Time.now.utc - rand(5).days }
    raw_text        { FFaker::Lorem.paragraphs.join("\n") }
    date            { published_at.to_date }
    features        { '{}' }
  end
end
