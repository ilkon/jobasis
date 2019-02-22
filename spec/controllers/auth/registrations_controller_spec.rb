# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::RegistrationsController, type: :controller do
  render_views
  include ActiveJob::TestHelper

  describe 'GET #new' do
    it 'responds with appropriate HTTP code' do
      get :new

      expect(response.response_code).to eq(200)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:params) { { name: 'John Doe', email: 'john@test.com', password: '123Qwerty123' } }

      it 'responds with appropriate HTTP code' do
        post :create, params: params

        expect(response.response_code).to eq(302)
      end

      it 'creates a new user with given params' do
        expect do
          post :create, params: params
        end.to change(User, :count).by(1)

        user = User.last

        expect(user).not_to be_nil
        expect(user.name).to eql(params[:name])
        expect(user.user_password).not_to be_nil
        expect(user.user_emails).not_to be_empty
        expect(user.user_emails.first.email).to eql(params[:email])
      end

      it 'strips and downcases sensitive params before creating user' do
        params = { name: ' John Doe  ', email: ' JOHNNY@test.com ', password: '    123Qwerty123  ' }

        expect do
          post :create, params: params
        end.to change(User, :count).by(1)

        user = User.last

        expect(user).not_to be_nil
        expect(user.name).to eql(params[:name].strip)
        expect(user.user_password).not_to be_nil
        expect(user.user_emails).not_to be_empty
        expect(user.user_emails.first.email).to eql(params[:email].strip.downcase)
      end

      it 'sends email about email confirm instructions' do
        expect do
          perform_enqueued_jobs do
            post :create, params: params
          end
        end.to change(ActionMailer::Base.deliveries, :count).by(1)

        delivered_email = ActionMailer::Base.deliveries.last
        expect(delivered_email.to).to include(params[:email])
        expect(delivered_email.subject).to eql(I18n.t('auth.mailer.confirm_email_instruction.subject'))
      end

      it 'sets confirm_token and confirm_sent_at time' do
        post :create, params: params
        user = User.last

        expect(user.user_emails.first.confirm_token).not_to be_nil
        expect(Time.now.to_i - user.user_emails.first.confirm_sent_at.to_i <= 1).to be true
      end

      it 'authenticates user with given params' do
        before_ts = Time.now.to_i
        post :create, params: params
        after_ts = Time.now.to_i

        user = User.last

        expect(session[:user_id]).to eql(user.id)
        expect(session[:user_name]).to eql(user.name)
        expect(session[:login_at]).not_to be_nil
        expect(session[:login_at]).to be_between(before_ts, after_ts)
      end
    end

    context 'with invalid parameters' do
      let(:params) { { email: 'john@test.com', password: '123Qwerty123' } }

      it 'responds with appropriate HTTP code' do
        post :create, params: params

        expect(response.response_code).to eq(200)
      end

      it 'does not save new user in the database' do
        expect do
          post :create, params: params
        end.to_not change(User, :count)
      end

      it 'returns details about validation error' do
        post :create, params: params

        expect(response.body).to include('Name can&#39;t be blank')
      end

      it 'returns details about validation error in nested associations' do
        create(:user, user_emails_attributes: [{ email: params[:email] }])

        post :create, params: params.merge(password: '')

        expect(response.body).to include('Name can&#39;t be blank')
        expect(response.body).to include('Password can&#39;t be blank')
        expect(response.body).to include('Email has already been taken')
      end

      it "doesn't send an email about email confirm instructions" do
        expect do
          perform_enqueued_jobs do
            post :create, params: params
          end
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end
  end
end
