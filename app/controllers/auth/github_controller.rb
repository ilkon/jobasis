# frozen_string_literal: true

require 'securerandom'

module Auth
  class GithubController < BaseController
    # GET /auth/github
    def new
      reset_session
      session[:oauth_state] = SecureRandom.hex(Auth.oauth_state_token_length)

      redirect_to Auth::Api::Github.authorize_url(session[:oauth_state])
    end

    # GET /auth/github_callback
    def create
      callback_params = params.permit(:code, :state)
      state = session[:oauth_state]
      reset_session

      unless callback_params[:state] && callback_params[:state] == state
        redirect_to root_path, error: I18n.t('auth.github.error')
        return
      end

      access_token = Auth::Api::Github.access_token(callback_params[:code], state)

      if access_token
        userinfo = Auth::Api::Github.userinfo(access_token)

        if userinfo
          uid = userinfo[:id]
          name = userinfo[:name]

          provider_id = UserSocialProfile::PROVIDERS[:github]
          user = User.find_by_social_profile(provider_id, uid)

          if user
            user.update(name: name) unless user.name == name

            sign_in!(user, oauth_provider: :github, oauth_access_token: access_token)
            redirect_to root_path
            return
          end

          email = userinfo[:email]
          user = User.find_by_email(email)

          if user
            user.update(name: name) unless user.name == name
            user.user_social_profiles.create(provider_id: provider_id, uid: uid)

            sign_in!(user, oauth_provider: :github, oauth_access_token: access_token)
            redirect_to root_path
            return
          end

          user = User.create(
            name:                            name,
            user_social_profiles_attributes: [
              {
                provider_id: provider_id,
                uid:         uid
              }
            ],
            user_emails_attributes:          [
              {
                email: email
              }
            ]
          )

          if user
            sign_in!(user, oauth_provider: :github, oauth_access_token: access_token)
            redirect_to root_path
            return
          end
        end
      end

      redirect_to root_path, error: I18n.t('auth.github.error')
    end
  end
end
