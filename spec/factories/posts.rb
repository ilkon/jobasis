# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    publisher_id { 1 }
    publisher_key { 'MyString' }
    employer_id { 1 }
    text { 'MyText' }
    features { '' }
  end
end
