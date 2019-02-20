# frozen_string_literal: true

module Auth
  class SessionsController < BaseController
    # POST /auth/login
    def create
      login_params = params.permit(:email, :password, :remember_me)

      @email = login_params[:email]
      user = User.find_by_email(@email)

      if user&.password?(login_params[:password])
        sign_in!(user, login_params[:remember_me].present?)
        redirect_to root_path
        return
      end

      flash.now[:error] = I18n.t('auth.session.login_error')
      render :new
    end

    # DELETE /auth/logout
    def destroy
      reset_session
      redirect_to root_path
    end
  end
end
