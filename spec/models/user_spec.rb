# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    obj = build(:user)
    expect(obj).to be_valid
  end

  it 'can be stored' do
    obj = create(:user)
    expect(obj.reload).to be_present
  end

  it 'is invalid without a name' do
    obj = build(:user, name: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid with an empty name' do
    obj = build(:user, name: '')
    expect(obj).not_to be_valid
  end

  it 'strips name before saving' do
    name = ' John Doe  '
    obj = create(:user, name: name)
    expect(obj.name).to eql(name.strip)
  end

  describe '.find_by_email' do
    let(:email) { 'foo@bar.com' }

    it "doesn't find if object is missing" do
      res = described_class.find_by_email(email)
      expect(res).to be_nil
    end

    it "doesn't find if email is invalid" do
      obj = create(:user)
      obj.user_emails << build(:user_email, user_id: nil, email: 'qwerty@test.com')

      res = described_class.find_by_email(email)
      expect(res).to be_nil
    end

    it 'finds if email is valid' do
      obj = create(:user)
      obj.user_emails << build(:user_email, user_id: nil, email: email)

      res = described_class.find_by_email(email)
      expect(res).to eql(obj)
    end

    it 'finds if email is not downcased' do
      email = 'Foo@BAR.com'
      obj = create(:user)
      obj.user_emails << build(:user_email, user_id: nil, email: email.downcase)

      res = described_class.find_by_email(email)
      expect(res).to eql(obj)
    end

    it 'finds if email is not stripped' do
      email = ' foo@bar.com '
      obj = create(:user)
      obj.user_emails << build(:user_email, user_id: nil, email: email.strip)

      res = described_class.find_by_email(email)
      expect(res).to eql(obj)
    end
  end

  describe '.find_by_social_profile' do
    let(:provider_id) { 1 }
    let(:uid) { 'qwerty' }

    it "doesn't find if object is missing" do
      res = described_class.find_by_social_profile(provider_id, uid)
      expect(res).to be_nil
    end

    it "doesn't find if uid is invalid" do
      obj = create(:user)
      obj.user_social_profiles << build(:user_social_profile, user_id: nil, provider_id: 1, uid: 'qqq')

      res = described_class.find_by_social_profile(provider_id, uid)
      expect(res).to be_nil
    end

    it 'finds if provider_id and uid are valid' do
      obj = create(:user)
      obj.user_social_profiles << build(:user_social_profile, user_id: nil, provider_id: provider_id, uid: uid)

      res = described_class.find_by_social_profile(provider_id, uid)
      expect(res).to eql(obj)
    end
  end
end
