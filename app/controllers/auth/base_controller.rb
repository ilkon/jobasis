# frozen_string_literal: true

module Auth
  class BaseController < ApplicationController
    layout 'auth'

    protected

    def sign_in!(user, remember_me = false)
      reset_session
      session[:user_id] = user.id
      session[:user_name] = user.name
      session[:remember_me] = 1 if remember_me
      session[:login_at] = Time.now.to_i
    end
  end
end
