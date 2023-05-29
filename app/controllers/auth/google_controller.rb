# frozen_string_literal: true

require 'securerandom'

module Auth
  class GoogleController < BaseController
    OAUTH_STATE_TOKEN_LENGTH = 24

    # GET /auth/google
    def new
      reset_session
      session[:oauth_state] = SecureRandom.hex(OAUTH_STATE_TOKEN_LENGTH)

      redirect_to Auth::Api::Google.authorize_url(session[:oauth_state], auth_google_callback_url), allow_other_host: true
    end

    # GET /auth/google_callback
    def create
      callback_params = params.permit(:code, :state)
      state = session[:oauth_state]
      reset_session

      unless callback_params[:state] && callback_params[:state] == state
        redirect_to root_path, error: I18n.t('auth.google.error')
        return
      end

      access_token = Auth::Api::Google.access_token(callback_params[:code], auth_google_callback_url)

      if access_token
        userinfo = Auth::Api::Google.userinfo(access_token)

        if userinfo
          uid = userinfo[:sub]
          name = userinfo[:name]

          provider_id = UserSocialProfile::PROVIDERS[:google]
          user = User.find_by_social_profile(provider_id, uid)

          if user
            user.update(name:) unless user.name == name

            sign_in!(user, oauth_provider: :google, oauth_access_token: access_token)
            redirect_to root_path
            return
          end

          email = userinfo[:email]
          user = User.find_by_email(email)

          if user
            user.update(name:) unless user.name == name
            user.user_social_profiles.create(provider_id:, uid:)

            sign_in!(user, oauth_provider: :google, oauth_access_token: access_token)
            redirect_to root_path
            return
          end

          user = User.create(
            name:,
            user_social_profiles_attributes: [
              {
                provider_id:,
                uid:
              }
            ],
            user_emails_attributes:          [
              {
                email:
              }
            ]
          )

          if user
            sign_in!(user, oauth_provider: :google, oauth_access_token: access_token)
            redirect_to root_path
            return
          end
        end
      end

      redirect_to root_path, error: I18n.t('auth.google.error')
    end
  end
end
