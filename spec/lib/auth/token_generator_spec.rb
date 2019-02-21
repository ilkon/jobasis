# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::TokenGenerator, type: :model do
  before :all do
    @token_generator = described_class.new(
      ActiveSupport::CachingKeyGenerator.new(
        ActiveSupport::KeyGenerator.new(Rails.application.credentials.dig(:secret_key_base))
      )
    )
  end

  after :all do
  end

  describe '.digest' do
    it 'generates encrypted token' do
      %i[reset_token confirm_token].each do |column|
        %w[token1 ABCABCABCABC !@#!@#ASD F -1].each do |token|
          digest = @token_generator.digest(column, token)
          expect(digest).not_to eql(token)
        end
      end
    end

    it 'generates different digests for different tokens and columns' do
      digests = []
      %i[reset_token confirm_token].each do |column|
        %w[token1 ABCABCABCABC !@#!@#ASD F -1].each do |token|
          digest = @token_generator.digest(column, token)
          expect(digests).not_to include(digest)
          digests << digest
        end
      end
    end
  end

  describe '.generate' do
    let(:token_length) { 48 }

    before :each do
      pwd = 'Super-SeCrEt=password_123'
      10.times { create(:user_password, password: pwd) }
      10.times { create(:user_email) }
    end

    it 'generates raw and encoded token' do
      [
        [UserPassword, :reset_token],
        [UserEmail, :confirm_token]
      ].each do |klass, column|
        token, encoded_token = @token_generator.generate(klass, column, token_length)
        expect(token).not_to be_nil
        expect(encoded_token).not_to be_nil
        expect(encoded_token).not_to eql(token)
      end
    end

    it 'generates raw tokens of given length' do
      [
        [UserPassword, :reset_token],
        [UserEmail, :confirm_token]
      ].each do |klass, column|
        token, = @token_generator.generate(klass, column, token_length)
        expect(token).not_to be_nil
        expect(token.length).to eql(token_length)
      end
    end

    it 'generates unique encoded tokens' do
      [
        [UserPassword, :reset_token],
        [UserEmail, :confirm_token]
      ].each do |klass, column|
        expect(klass.count).to eql(10)

        encoded_tokens = []
        klass.all.each do |item|
          _, encoded_token = @token_generator.generate(klass, column, token_length)
          item.send("#{column}=", encoded_token)
          item.save(validate: false)
          expect(encoded_tokens).not_to include(encoded_token)
          encoded_tokens << encoded_token
        end
      end
    end

    it 'generates raw and encoded tokens which can be matched with digest' do
      [
        [UserPassword, :reset_token],
        [UserEmail, :confirm_token]
      ].each do |klass, column|
        expect(klass.count).to eql(10)

        klass.all.each do |item|
          token, encoded_token = @token_generator.generate(klass, column, token_length)
          item.send("#{column}=", encoded_token)
          item.save(validate: false)
          digest = @token_generator.digest(column, token)
          expect(encoded_token).to eql(digest)
        end
      end
    end
  end
end
