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
          Auth::Mailer.reset_password_instruction(forgot_params[:email], user, token).deliver_now
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
          @error = I18n.t('auth.password.expired_token')
        end
      else
        @error = I18n.t('auth.password.invalid_token')
      end
    end

    # Changing password confirmed by reset_token
    def update
      reset_params = params.permit(:token, :password)

      @token = reset_params[:token]
      password = UserPassword.find_by_reset_token(@token)

      if password
        if password.reset_sent_at.to_i + Auth.reset_password_token_ttl.to_i > Time.now.utc.to_i

          if password.update(password: reset_params[:password])
            password.clear_reset_token

            email = password.user.user_emails.first
            Auth::Mailer.changed_password_notification(email.email, password.user).deliver_now if email

            sign_in!(password.user)
            @success = true

          else
            @password_error = password.errors[:password].first
          end

        else
          @error = I18n.t('auth.password.expired_token')
        end
      else
        @error = I18n.t('auth.password.invalid_token')
      end

      render :edit
    end
  end
end
