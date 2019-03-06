# frozen_string_literal: true

require 'securerandom'

module Auth
  class GithubController < BaseController
    AUTHORIZE_URL = 'https://github.com/login/oauth/authorize'
    TOKEN_URL = 'https://github.com/login/oauth/access_token'
    USERINFO_URL = 'https://api.github.com/user'

    # GET /auth/github
    def new
      reset_session
      session[:oauth2_state] = SecureRandom.hex(24)

      query_values = {
        client_id: Rails.application.credentials.dig(:github, :client_id),
        state:     session[:oauth2_state]
      }

      redirect_to AUTHORIZE_URL + '?' + query_values.to_query
    end

    # GET /auth/github_callback
    def create
      callback_params = params.permit(:code, :state)
      state = session[:oauth2_state]
      reset_session

      unless callback_params[:state] && callback_params[:state] == state
        redirect_to root_path, notice: I18n.t('auth.github.error')
        return
      end

      # Requesting for access token
      options = {
        params:  {
          client_id:     Rails.application.credentials.dig(:github, :client_id),
          client_secret: Rails.application.credentials.dig(:github, :client_secret),
          code:          callback_params[:code],
          state:         state
        },
        headers: {
          Accept: 'application/json'
        }
      }
      response = Typhoeus.post(TOKEN_URL, options)

      if response.success?
        resp = JSON.parse(response.response_body, symbolize_names: true)
        if resp.is_a?(Hash) && resp[:access_token]
          # Requesting for user info
          options = {
            headers: {
              Authorization: "token #{resp[:access_token]}"
            }
          }
          response = Typhoeus.get(USERINFO_URL, options)

          if response.success?
            resp = JSON.parse(response.response_body, symbolize_names: true)

            uid = resp[:id]
            name = resp[:name]

            provider_id = UserSocialProfile::PROVIDERS[:github]
            user = User.find_by_social_profile(provider_id, uid)

            if user
              user.update(name: name) unless user.name == name

              sign_in!(user, true)
              redirect_to root_path
              return
            end

            email = resp[:email]
            user = User.find_by_email(email)

            if user
              user.update(name: name) unless user.name == name
              user.user_social_profiles.create(provider_id: provider_id, uid: uid)

              sign_in!(user, true)
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
              sign_in!(user, true)
              redirect_to root_path
              return
            end
          end
        end
      end

      redirect_to root_path, notice: I18n.t('auth.github.error')
    end
  end
end
