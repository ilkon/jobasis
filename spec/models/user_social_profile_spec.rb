# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSocialProfile, type: :model do
  it 'has a valid factory' do
    obj = build(:user_social_profile)
    expect(obj).to be_valid
  end

  it 'can be stored' do
    obj = create(:user_social_profile)
    expect(obj.reload).to be_present
  end

  it 'is invalid without user_id' do
    obj = build(:user_social_profile, user_id: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid without provider_id' do
    obj = build(:user_social_profile, provider_id: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid with invalid provider_id' do
    obj = build(:user_social_profile, provider_id: UserSocialProfile::PROVIDERS.values.max + 1)
    expect(obj).not_to be_valid
  end

  it 'is invalid without uid' do
    obj = build(:user_social_profile, uid: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid with empty uid' do
    obj = build(:user_social_profile, uid: '')
    expect(obj).not_to be_valid
  end

  it 'is invalid with duplicate provider_id + uid' do
    prev = create(:user_social_profile)
    obj = build(:user_social_profile, provider_id: prev.provider_id, uid: prev.uid)
    expect(obj).not_to be_valid
  end

  it 'is valid with the same provider_id but different uid' do
    prev = create(:user_social_profile)
    obj = build(:user_social_profile, provider_id: prev.provider_id, uid: "#{prev.uid}a")
    expect(obj).to be_valid
  end
end
