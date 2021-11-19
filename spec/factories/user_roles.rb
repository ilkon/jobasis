# frozen_string_literal: true

FactoryBot.define do
  factory :common_user_role, class: 'UserRole' do
    association :user, strategy: :create

    admin { false }
  end

  factory :admin_user_role, class: 'UserRole' do
    association :user, strategy: :create

    admin { true }
  end
end
