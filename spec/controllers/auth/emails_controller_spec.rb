# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::EmailsController, type: :controller do
  render_views

  describe 'GET #confirm' do
    before :each do
      @user = create(:user)
      @user.user_emails << build(:user_email, user_id: nil)

      @token = @user.user_emails.first.set_confirm_token

      @params = { token: @token }
    end

    context 'with valid parameters' do
      it 'responds with appropriate HTTP code' do
        get :confirm, params: @params

        expect(response.response_code).to eq(200)
      end

      it 'clears confirm token' do
        expect(@user.user_emails.first.confirm_token).not_to be_nil
        expect(@user.user_emails.first.confirm_sent_at).not_to be_nil

        get :confirm, params: @params
        @user.reload

        expect(@user.user_emails.first.confirm_token).to be_nil
        expect(@user.user_emails.first.confirm_sent_at).to be_nil
      end

      it 'sets confirmed_at timestamp' do
        expect(@user.user_emails.first.confirmed_at).to be_nil

        get :confirm, params: @params

        expect(@user.user_emails.first.confirmed_at).not_to be_nil
      end

      it 'authenticates user' do
        before_ts = Time.now.to_i
        get :confirm, params: @params
        after_ts = Time.now.to_i

        expect(session[:user_id]).to eql(@user.id)
        expect(session[:user_name]).to eql(@user.name)
        expect(session[:login_at]).not_to be_nil
        expect(session[:login_at]).to be_between(before_ts, after_ts)
      end
    end

    context 'with valid but expired parameters' do
      it 'responds with appropriate HTTP code' do
        Timecop.travel(Auth.confirm_email_token_ttl + 1.minute) do
          get :confirm, params: @params

          expect(response.response_code).to eq(200)
        end
      end

      it 'returns details about validation error' do
        Timecop.travel(Auth.confirm_email_token_ttl + 1.minute) do
          get :confirm, params: @params

          expect(response.body).to include(I18n.t('auth.email.expired_token'))
        end
      end
    end

    context 'with invalid parameters' do
      it 'responds with appropriate HTTP code' do
        get :confirm, params: { token: "#{@token}!" }

        expect(response.response_code).to eq(200)
      end

      it 'responds with appropriate HTTP code if token is blank' do
        get :confirm

        expect(response.response_code).to eq(200)
      end

      it 'returns details about validation error' do
        get :confirm

        expect(response.body).to include(I18n.t('auth.email.invalid_token'))
      end
    end
  end
end
