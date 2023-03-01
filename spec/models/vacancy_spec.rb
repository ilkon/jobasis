# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vacancy do
  it 'has a valid factory' do
    obj = build(:vacancy)
    expect(obj).to be_valid
  end

  it 'can be stored' do
    obj = create(:vacancy)
    expect(obj.reload).to be_present
  end

  it 'is invalid without a publisher' do
    obj = build(:vacancy, publisher_id: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid without a post' do
    obj = build(:vacancy, post_id: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid without publishing time' do
    obj = build(:vacancy)
    obj.published_at = nil
    expect(obj).not_to be_valid
  end

  it 'is invalid without a date' do
    obj = build(:vacancy, date: nil)
    expect(obj).not_to be_valid
  end
end
