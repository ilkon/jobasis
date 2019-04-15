# frozen_string_literal: true

module Auth
  class PasswordsController < BaseController
    # POST /auth/forgot_password
    def create
      forgot_params = params.permit(:email)

      @email = forgot_params[:email]
      user = User.find_by_email(@email)

      if user
        if user.user_password
          token = user.user_password.set_reset_token
          Auth::Mailer.reset_password_instruction(forgot_params[:email], user, token).deliver_later
          @success = true
        else
          flash.now[:error] = I18n.t('auth.password.no_password')
        end
      else
        flash.now[:error] = I18n.t('auth.password.no_user')
      end

      render :new
    end

    # GET /auth/reset_password?token=abcdef
    def edit
      reset_params = params.permit(:token)

      @token = reset_params[:token]
      password = UserPassword.find_by_reset_token(@token)

      if password
        if password.reset_sent_at.to_i + Auth.reset_password_token_ttl.to_i > Time.now.to_i
        else
          @token_error = I18n.t('auth.password.expired_token')
        end
      else
        @token_error = I18n.t('auth.password.invalid_token')
      end
    end

    # POST /auth/reset_password
    def update
      reset_params = params.permit(:token, :password)

      @token = reset_params[:token]
      password = UserPassword.find_by_reset_token(@token)

      if password
        if password.reset_sent_at.to_i + Auth.reset_password_token_ttl.to_i > Time.now.to_i

          if password.update(password: reset_params[:password])
            password.clear_reset_token

            email = password.user.user_emails.first
            Auth::Mailer.changed_password_notification(email.email, password.user).deliver_later if email

            sign_in!(password.user)
            @success = true

          else
            @errors = {
              password: password.errors[:password].first
            }
          end
        else
          @token_error = I18n.t('auth.password.expired_token')
        end
      else
        @token_error = I18n.t('auth.password.invalid_token')
      end

      render :edit
    end
  end
end
