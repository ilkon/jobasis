# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublisherStash, type: :model do
  it 'has a valid factory' do
    obj = build(:publisher_stash)
    expect(obj).to be_valid
  end

  it 'can be stored' do
    obj = create(:publisher_stash)
    expect(obj.reload).to be_present
  end

  it 'is invalid without a publisher' do
    obj = build(:publisher_stash, publisher_id: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid with an empty key' do
    obj = build(:publisher_stash, publisher_key: '')
    expect(obj).not_to be_valid
  end

  it 'is invalid with a duplicate key' do
    obj2 = create(:publisher_stash)
    obj = build(:publisher_stash, publisher: obj2.publisher, publisher_key: obj2.publisher_key)
    expect(obj).not_to be_valid
  end

  it 'is valid with a duplicate key from different provider' do
    obj2 = create(:publisher_stash)
    obj = build(:publisher_stash, publisher_key: obj2.publisher_key)
    expect(obj).to be_valid
  end
end
