# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::PasswordsController do
  render_views
  include ActiveJob::TestHelper

  describe 'GET #new' do
    it 'responds with appropriate HTTP code' do
      get :new

      expect(response.response_code).to eq(200)
    end
  end

  describe 'POST #create' do
    before :all do
      @params = { email: 'john@test.com' }

      @user = create(:user)
      @user.user_emails << build(:user_email, user_id: nil, email: @params[:email])
      @user.create_user_password(password: '123Qwerty123!')
    end

    after :all do
      @user.destroy
    end

    context 'with valid parameters' do
      it 'responds with appropriate HTTP code' do
        post :create, params: @params

        expect(response.response_code).to eq(200)
      end

      it 'sends email about password reset instructions' do
        expect do
          perform_enqueued_jobs do
            post :create, params: @params
          end
        end.to change(ActionMailer::Base.deliveries, :count).by(1)

        delivered_email = ActionMailer::Base.deliveries.last
        expect(delivered_email.to).to include(@params[:email])
        expect(delivered_email.subject).to eql(I18n.t('auth.mailer.reset_password_instruction.subject'))
      end

      it 'sets reset_token and reset_sent_at time' do
        @user.user_password.clear_reset_token
        expect(@user.user_password.reset_token).to be_nil
        expect(@user.user_password.reset_sent_at).to be_nil

        post :create, params: @params
        @user.reload

        expect(@user.user_password.reset_token).not_to be_nil
        expect(@user.user_password.reset_sent_at.to_i).to eql(Time.now.to_i)
      end
    end

    context 'with valid parameters for social user' do
      before :all do
        @params2 = { email: 'adam@test.com' }

        @user2 = create(:user)
        @user2.user_emails << build(:user_email, user_id: nil, email: @params2[:email])
        @user2.user_social_profiles << build(:user_social_profile, user_id: nil, provider_id: 1, uid: 'qqq')
      end

      after :all do
        @user2.destroy
      end

      it 'responds with appropriate HTTP code' do
        post :create, params: @params2

        expect(response.response_code).to eq(422)
      end

      it 'returns an error message why reset instructions cannot be sent' do
        post :create, params: @params2

        expect(response.body).to include(I18n.t('auth.password.no_password'))
      end
    end

    context 'with invalid parameters' do
      let(:params) { { email: 'della@test.com' } }

      it 'responds with appropriate HTTP code' do
        post(:create, params:)

        expect(response.response_code).to eq(422)
      end

      it "doesn't send an email about password reset instructions" do
        expect do
          perform_enqueued_jobs do
            post :create, params:
          end
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end
  end

  describe 'GET #edit' do
    before :all do
      @user = create(:user)
      @user.user_emails << build(:user_email, user_id: nil)
      @user.create_user_password(password: '123Qwerty123')

      @token = @user.user_password.set_reset_token

      @params = { token: @token }
    end

    after :all do
      @user.destroy
    end

    context 'with valid parameters' do
      it 'responds with appropriate HTTP code' do
        get :edit, params: @params

        expect(response.response_code).to eq(200)
      end
    end

    context 'with valid but expired parameters' do
      it 'responds with appropriate HTTP code' do
        Timecop.travel(Authonomy.reset_password_token_ttl + 1.minute) do
          get :edit, params: @params

          expect(response.response_code).to eq(200)
        end
      end

      it 'returns details about validation error' do
        Timecop.travel(Authonomy.reset_password_token_ttl + 1.minute) do
          get :edit, params: @params

          expect(response.body).to include(I18n.t('auth.password.expired_token'))
        end
      end
    end

    context 'with invalid parameters' do
      it 'responds with appropriate HTTP code' do
        get :edit, params: { token: "#{@token}!" }

        expect(response.response_code).to eq(200)
      end

      it 'responds with appropriate HTTP code if token is blank' do
        get :edit

        expect(response.response_code).to eq(200)
      end

      it 'returns details about validation error' do
        get :edit

        expect(response.body).to include(I18n.t('auth.password.invalid_token'))
      end
    end
  end

  describe 'POST #update' do
    before do
      @user = create(:user)
      @user.user_emails << build(:user_email, user_id: nil)
      @user.create_user_password(password: '123Qwerty123')

      @token = @user.user_password.set_reset_token
      @password = 'New=Super_password+123'

      @params = { token: @token, password: @password }
    end

    context 'with valid parameters' do
      it 'responds with appropriate HTTP code' do
        post :update, params: @params

        expect(response.response_code).to eq(200)
      end

      it 'updates user password' do
        expect(@user).not_to be_password(@password)

        post :update, params: @params
        @user.reload

        expect(@user).to be_password(@password)
      end

      it 'clears reset token after updating password' do
        expect(@user.user_password.reset_token).not_to be_nil
        expect(@user.user_password.reset_sent_at).not_to be_nil

        post :update, params: @params
        @user.reload

        expect(@user.user_password.reset_token).to be_nil
        expect(@user.user_password.reset_sent_at).to be_nil
      end

      it 'sends email about changed password' do
        expect do
          perform_enqueued_jobs do
            post :update, params: @params
          end
        end.to change(ActionMailer::Base.deliveries, :count).by(1)

        delivered_email = ActionMailer::Base.deliveries.last
        expect(delivered_email.to).to include(@user.user_emails.first.email)
        expect(delivered_email.subject).to eql(I18n.t('auth.mailer.changed_password_notification.subject'))
      end

      it 'authenticates user' do
        before_ts = Time.now.to_i
        post :update, params: @params
        after_ts = Time.now.to_i

        expect(session[:user_id]).to eql(@user.id)
        expect(session[:user_name]).to eql(@user.name)
        expect(session[:login_at]).not_to be_nil
        expect(session[:login_at]).to be_between(before_ts, after_ts)
      end
    end

    context 'with valid but expired parameters' do
      it 'responds with appropriate HTTP code' do
        Timecop.travel(Authonomy.reset_password_token_ttl + 1.minute) do
          post :update, params: @params

          expect(response.response_code).to eq(422)
        end
      end

      it 'returns details about validation error' do
        Timecop.travel(Authonomy.reset_password_token_ttl + 1.minute) do
          post :update, params: @params

          expect(response.body).to include(I18n.t('auth.password.expired_token'))
        end
      end

      it "doesn't update user password" do
        Timecop.travel(Authonomy.reset_password_token_ttl + 1.minute) do
          expect(@user).not_to be_password(@password)

          post :update, params: @params
          @user.reload

          expect(@user).not_to be_password(@password)
        end
      end
    end

    context 'with invalid parameters' do
      it 'responds with appropriate HTTP code' do
        post :update, params: @params.merge(token: "#{@token}!")

        expect(response.response_code).to eq(422)
      end

      it 'responds with appropriate HTTP code if token is blank' do
        post :update, params: @params.merge(token: nil)

        expect(response.response_code).to eq(422)
      end

      it 'returns details about validation error' do
        post :update, params: @params.merge(password: nil)

        expect(response.body).to include('Password can&#39;t be blank')
      end

      it 'returns details about token validation error' do
        post :update, params: @params.merge(token: nil)

        expect(response.body).to include(I18n.t('auth.password.invalid_token'))
      end

      it "doesn't update user password" do
        expect(@user).not_to be_password(@password)

        post :update, params: @params.merge(token: "#{@token}!")
        @user.reload

        expect(@user).not_to be_password(@password)
      end
    end
  end
end
