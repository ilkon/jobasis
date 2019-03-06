# frozen_string_literal: true

module Auth
  class SessionsController < BaseController
    # POST /auth/login
    def create
      login_params = params.permit(:email, :password, :remember_me)

      user = User.find_by_email(login_params[:email])

      if user&.password?(login_params[:password])
        sign_in!(user, login_params[:remember_me].present?)
        redirect_to root_path

      else
        @values = login_params.to_h.select { |k, _v| %i[email].include?(k.to_sym) }
        flash.now[:error] = I18n.t('auth.session.login_error')

        render :new
      end
    end

    # GET /auth/github
    def github
      redirect_to "https://github.com/login/oauth/authorize?client_id=#{Rails.application.credentials.dig(:github, :client_id)}"
    end

    # GET /auth/oauth2callback
    def oauth2callback; end

    # DELETE /auth/logout
    def destroy
      reset_session
      redirect_to root_path
    end
  end
end
