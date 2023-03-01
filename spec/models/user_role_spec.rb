# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRole do
  it 'has a valid factory' do
    obj = build(:common_user_role)
    expect(obj).to be_valid
  end

  it 'can be stored' do
    obj = create(:common_user_role)
    expect(obj.reload).to be_present
  end

  it 'is invalid without user_id' do
    obj = build(:common_user_role, user_id: nil)
    expect(obj).not_to be_valid
  end
end
