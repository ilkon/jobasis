# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publisher, type: :model do
  it 'has a valid factory' do
    obj = build(:publisher)
    expect(obj).to be_valid
  end

  it 'can be stored' do
    obj = create(:publisher)
    expect(obj.reload).to be_present
  end

  it 'is invalid without a name' do
    obj = build(:publisher, name: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid with an empty name' do
    obj = build(:publisher, name: '')
    expect(obj).not_to be_valid
  end

  it 'is invalid with duplicate name' do
    obj2 = create(:publisher)
    obj  = build(:publisher, name: obj2.name)
    expect(obj).not_to be_valid
  end

  it 'strips name before saving' do
    name = ' Hacker News  '
    obj = create(:publisher, name: name)
    expect(obj.name).to eql(name.strip)
  end
end
