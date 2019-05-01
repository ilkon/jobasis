# frozen_string_literal: true

module Auth
  class BaseController < ApplicationController
    protected

    def sign_in!(user, remember_me: false, oauth_provider: nil, oauth_access_token: nil)
      reset_session
      session[:user_id] = user.id
      session[:user_name] = user.name
      session[:remember_me] = 1 if remember_me
      session[:oauth_provider] = oauth_provider if oauth_provider
      session[:oauth_access_token] = oauth_access_token if oauth_access_token
      session[:login_at] = Time.now.to_i
    end
  end
end
