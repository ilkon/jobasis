# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPassword, type: :model do
  it 'has a valid factory' do
    obj = build(:user_password)
    expect(obj).to be_valid
  end

  it 'can be stored' do
    obj = create(:user_password)
    expect(obj.reload).to be_present
  end

  it 'is invalid without user_id' do
    obj = build(:user_password, user_id: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid without a password' do
    obj = build(:user_password, password: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid with an empty password' do
    obj = build(:user_password, password: '')
    expect(obj).not_to be_valid
  end

  it 'is invalid with a short password' do
    obj = build(:user_password, password: 'short')
    expect(obj).not_to be_valid
  end

  it 'is invalid with a very long password' do
    obj = build(:user_password, password: 'x' * 100)
    expect(obj).not_to be_valid
  end

  it 'is valid with a valid password' do
    obj = build(:user_password, password: 'SuperCoolPwd123!')
    expect(obj).to be_valid
  end

  it 'strips password before saving' do
    pwd = ' 123maMAma123!  '
    obj = create(:user_password, password: pwd)
    expect(obj).to be_match(pwd.strip)
  end

  it 'generates hashed password when setting password' do
    obj = create(:user_password)
    expect(obj.encrypted_password).to be_present
  end

  it 'generates hashed password different from given password' do
    obj = create(:user_password)
    expect(obj.encrypted_password).not_to eql(obj.password)
  end

  it 'generates new hash password again if password has changed' do
    obj = create(:user_password, password: 'oldPassword_123')
    encrypted_password = obj.encrypted_password.dup
    obj.password = 'newPassword_321'
    obj.save
    expect(obj.encrypted_password).not_to eql(encrypted_password)
  end

  it 'generates different hashed passwords for the same password' do
    pwd = '123maMAma123!'
    obj1 = create(:user_password, password: pwd)
    obj2 = create(:user_password, password: pwd)
    expect(obj1.encrypted_password).not_to eql(obj2.encrypted_password)
  end

  describe '.match?' do
    let(:pwd) { 'Super-SeCrEt=password_123' }

    it 'matches valid password' do
      obj = create(:user_password, password: pwd)
      expect(obj).to be_match(pwd)
    end

    it 'matches valid non-stripped password' do
      obj = create(:user_password, password: pwd)
      expect(obj).to be_match(" #{pwd}  ")
    end

    it "doesn't match invalid password" do
      obj = create(:user_password, password: pwd)
      expect(obj).not_to be_match('not-my-password')
    end
  end

  describe '.set_reset_token' do
    it 'creates and saves encoded reset_token' do
      obj = create(:user_password)
      expect(obj.reset_token).to be_nil
      obj.set_reset_token
      expect(obj.reset_token).not_to be_nil
    end

    it 'updates reset_sent_at time' do
      obj = create(:user_password)
      expect(obj.reset_sent_at).to be_nil
      obj.set_reset_token
      expect(obj.reset_sent_at).not_to be_nil
    end

    it 'generates encrypted token different from returning token' do
      obj = create(:user_password)
      token = obj.set_reset_token
      expect(obj.reset_token).not_to eql(token)
    end

    it 'returns a token that can be matched with saved encoded token' do
      obj = create(:user_password)
      token = obj.set_reset_token
      expect(obj.reset_token).to eql(Auth::TokenGenerator.generator.digest(:reset_token, token))
    end
  end

  describe '.clear_reset_token' do
    it 'deletes encoded reset_token and reset_sent_at time' do
      obj = create(:user_password)
      obj.set_reset_token
      expect(obj.reset_token).not_to be_nil
      expect(obj.reset_sent_at).not_to be_nil

      obj.clear_reset_token

      expect(obj.reset_token).to be_nil
      expect(obj.reset_sent_at).to be_nil
    end
  end

  describe '.find_by_reset_token' do
    it "doesn't find if object is missing" do
      res = described_class.find_by_reset_token(nil)
      expect(res).to be_nil
    end

    it "doesn't find if token is invalid" do
      obj = create(:user_password)
      token = obj.set_reset_token

      res = described_class.find_by_reset_token("#{token}!")
      expect(res).to be_nil
    end

    it 'finds if token is valid' do
      obj = create(:user_password)
      token = obj.set_reset_token

      res = described_class.find_by_reset_token(token)
      expect(res).to eql(obj)
    end
  end
end
