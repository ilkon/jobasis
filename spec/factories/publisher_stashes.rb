# frozen_string_literal: true

FactoryBot.define do
  factory :publisher_stash do
    association     :publisher, strategy: :build
    publisher_key   { FFaker::Guid.guid }
    last_fetched_at { Time.now - rand(10).days }
    content         { '[]' }
  end
end
