# frozen_string_literal: true

FactoryBot.define do
  factory :skill do
    sequence(:name) { |n| "#{FFaker::Skill.tech_skill} #{n}" }
  end
end
