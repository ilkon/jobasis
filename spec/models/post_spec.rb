# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post do
  it 'has a valid factory' do
    obj = build(:post)
    expect(obj).to be_valid
  end

  it 'can be stored' do
    obj = create(:post)
    expect(obj.reload).to be_present
  end

  it 'is invalid without a publisher' do
    obj = build(:post, publisher_id: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid without publishing time' do
    obj = build(:post)
    obj.published_at = nil
    expect(obj).not_to be_valid
  end

  it 'is invalid without a date' do
    obj = build(:post, date: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid with an empty key' do
    obj = build(:post, publisher_key: '')
    expect(obj).not_to be_valid
  end

  it 'is invalid with a duplicate key' do
    obj2 = create(:post)
    obj = build(:post, publisher: obj2.publisher, publisher_key: obj2.publisher_key)
    expect(obj).not_to be_valid
  end

  it 'is valid with a duplicate key from different provider' do
    obj2 = create(:post)
    obj = build(:post, publisher_key: obj2.publisher_key)
    expect(obj).to be_valid
  end
end
