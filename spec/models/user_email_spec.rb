# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserEmail do
  it 'has a valid factory' do
    obj = build(:user_email)
    expect(obj).to be_valid
  end

  it 'can be stored' do
    obj = create(:user_email)
    expect(obj.reload).to be_present
  end

  it 'is invalid without user_id' do
    obj = build(:user_email, user_id: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid without an email' do
    obj = build(:user_email, email: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid with invalid email' do
    %w[invalid_email_format 123 $$$ () ☃ bla@bla.].each do |email|
      obj = build(:user_email, email:)
      expect(obj).not_to be_valid
    end
  end

  it 'is valid with a valid email' do
    %w[a.b.c@example.com test_mail@gmail.com any+1@any.net email@test.br 123@mail.test].each do |email|
      obj = build(:user_email, email:)
      expect(obj).to be_valid
    end
  end

  it 'is invalid with a duplicate email' do
    prev = create(:user_email)
    obj = build(:user_email, email: prev.email)
    expect(obj).not_to be_valid
  end

  it 'downcases email before saving' do
    email = 'Foo@BAR.com'
    obj = create(:user_email, email:)
    expect(obj.email).to eql(email.downcase)
  end

  it 'strips email before saving' do
    email = ' foo@bar.com  '
    obj = create(:user_email, email:)
    expect(obj.email).to eql(email.strip)
  end

  it 'can be deleted' do
    obj = create(:user_email)
    expect do
      obj.destroy
    end.to change(described_class, :count).by(-1)
  end

  it 'cannot be deleted if confirmed' do
    obj = create(:user_email, confirmed_at: Time.zone.now)
    expect do
      obj.destroy
    end.not_to change(described_class, :count)
  end

  describe '.set_confirm_token' do
    it 'creates and saves encoded confirm_token' do
      obj = create(:user_email)
      expect(obj.confirm_token).to be_nil
      obj.set_confirm_token
      expect(obj.confirm_token).not_to be_nil
    end

    it 'updates confirm_sent_at time' do
      obj = create(:user_email)
      expect(obj.confirm_sent_at).to be_nil
      obj.set_confirm_token
      expect(obj.confirm_sent_at).not_to be_nil
    end

    it 'generates encrypted token different from returning token' do
      obj = create(:user_email)
      token = obj.set_confirm_token
      expect(obj.confirm_token).not_to eql(token)
    end

    it 'returns a token that can be matched with saved encoded token' do
      obj = create(:user_email)
      token = obj.set_confirm_token
      expect(obj.confirm_token).to eql(Authonomy::TokenGenerator.generator.digest(:confirm_token, token))
    end
  end

  describe '.clear_confirm_token' do
    it 'deletes encoded confirm_token and confirm_sent_at time' do
      obj = create(:user_email)
      obj.set_confirm_token
      expect(obj.confirm_token).not_to be_nil
      expect(obj.confirm_sent_at).not_to be_nil

      obj.clear_confirm_token

      expect(obj.confirm_token).to be_nil
      expect(obj.confirm_sent_at).to be_nil
    end
  end

  describe '.find_by_confirm_token' do
    it "doesn't find if object is missing" do
      res = described_class.find_by_confirm_token(nil)
      expect(res).to be_nil
    end

    it "doesn't find if token is invalid" do
      obj = create(:user_email)
      token = obj.set_confirm_token

      res = described_class.find_by_confirm_token("#{token}!")
      expect(res).to be_nil
    end

    it 'finds if token is valid' do
      obj = create(:user_email)
      token = obj.set_confirm_token

      res = described_class.find_by_confirm_token(token)
      expect(res).to eql(obj)
    end
  end
end
