# frozen_string_literal: true

FactoryBot.define do
  factory :vacancy do
    association     :publisher, strategy: :build
    association     :post, strategy: :build
    association     :employer, strategy: :build
    published_at    { Time.now.utc - 5.days - rand(5).days }
    date            { published_at.to_date }
  end
end
