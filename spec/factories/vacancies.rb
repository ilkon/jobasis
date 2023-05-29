# frozen_string_literal: true

FactoryBot.define do
  factory :vacancy do
    publisher     { { strategy: :build } }
    post          { { strategy: :build } }
    employer      { { strategy: :build } }

    published_at  { Time.now.utc - 5.days - rand(5).days }
    date          { published_at.to_date }
    text          { FFaker::Lorem.paragraph(5) }
  end
end
