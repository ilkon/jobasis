# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Skill, type: :model do
  it 'has a valid factory' do
    obj = build(:skill)
    expect(obj).to be_valid
  end

  it 'can be stored' do
    obj = create(:skill)
    expect(obj.reload).to be_present
  end

  it 'is invalid without a name' do
    obj = build(:skill, name: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid with an empty name' do
    obj = build(:skill, name: '')
    expect(obj).not_to be_valid
  end

  it 'is invalid with duplicate name' do
    obj2 = create(:skill)
    obj  = build(:skill, name: obj2.name)
    expect(obj).not_to be_valid
  end

  it 'strips name before saving' do
    name = ' PHP   '
    obj = create(:skill, name: name)
    expect(obj.name).to eql(name.strip)
  end
end
