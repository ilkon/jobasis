# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::SessionsController do
  render_views

  describe 'GET #new' do
    it 'responds with appropriate HTTP code' do
      get :new

      expect(response.response_code).to eq(200)
    end
  end

  describe 'POST #create' do
    before :all do
      @params = { email: 'john@test.com', password: '123Qwerty123!' }

      @user = create(:user)
      @user.user_emails << build(:user_email, user_id: nil, email: @params[:email])
      @user.create_user_password(password: @params[:password])
    end

    after :all do
      @user.destroy
    end

    context 'with valid parameters' do
      it 'responds with appropriate HTTP code' do
        post :create, params: @params

        expect(response.response_code).to eq(302)
      end

      it 'authenticates user with given params' do
        before_ts = Time.now.to_i
        post :create, params: @params
        after_ts = Time.now.to_i

        expect(session[:user_id]).to eql(@user.id)
        expect(session[:user_name]).to eql(@user.name)
        expect(session[:login_at]).not_to be_nil
        expect(session[:login_at]).to be_between(before_ts, after_ts)
      end
    end

    context 'with invalid parameters' do
      let(:params) { { email: 'delladella@test.com', password: 'Asasasasa9876' } }

      it 'responds with appropriate HTTP code' do
        post(:create, params:)

        expect(response.response_code).to eq(422)
      end

      it 'returns details about validation error' do
        post(:create, params:)

        expect(response.body).to include(I18n.t('auth.session.login_error'))
      end

      it 'does not authenticate user' do
        post(:create, params:)

        expect(session[:user_id]).to be_falsey
        expect(session[:user_name]).to be_falsey
        expect(session[:login_at]).to be_falsey
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'responds with appropriate HTTP code' do
      delete :destroy

      expect(response.response_code).to eq(302)
    end

    it 'destroys user session' do
      session[:user_id] = 1
      session[:user_name] = 'John'
      session[:login_at] = Time.now.to_i

      delete :destroy

      expect(session[:user_id]).to be_falsey
      expect(session[:user_name]).to be_falsey
      expect(session[:login_at]).to be_falsey
    end
  end
end
