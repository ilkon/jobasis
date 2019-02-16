# frozen_string_literal: true

module Auth
  class PasswordsController < BaseController
    # Handler of "Forgot Password?" form
    def create
      perm_params = params.permit(:email)

      user = User.find_by_email(perm_params[:email])

      if user
        if user.user_password
          token = user.user_password.set_reset_token
          Auth::Mailer.reset_password_instruction(perm_params[:email], user, token).deliver_later

          head :ok
        else
          render json: { errors: { common: [I18n.t('auth.password.user_has_no_password')] } }, status: :unprocessable_entity
        end
      else
        head :ok
      end
    end

    # Confirming password change by reset_token
    def edit
      # perm_params = params.permit(:token)
      #
      # password = UserPassword.find_by_reset_token(perm_params[:token])
      # if password
      #   if password.reset_sent_at.to_i + Auth.reset_password_token_ttl.to_i > Time.now.utc.to_i
      #     head :ok
      #   else
      #     render json: { errors: { common: [I18n.t('auth.password.expired_token')] } }, status: :unprocessable_entity
      #   end
      # else
      #   render json: { errors: { common: [I18n.t('auth.password.invalid_token')] } }, status: :unprocessable_entity
      # end
    end

    # Changing password confirmed by reset_token
    def update
      perm_params = params.permit(:token, :password)

      password = UserPassword.find_by_reset_token(perm_params[:token])
      if password
        if password.reset_sent_at.to_i + Auth.reset_password_token_ttl.to_i > Time.now.utc.to_i

          if password.update(password: perm_params[:password])
            password.clear_reset_token

            email = password.user.user_emails.first
            Auth::Mailer.changed_password_notification(email.email, password.user).deliver_later if email

            sign_in!(password.user)
            head :ok

          else
            errors = password.errors.to_hash.each_with_object({}) { |(k, v), hash| hash[k.to_s.split('.').last] = v }
            render json: { errors: errors }, status: :unprocessable_entity
          end

        else
          render json: { errors: { common: [I18n.t('auth.password.expired_token')] } }, status: :unprocessable_entity
        end
      else
        render json: { errors: { common: [I18n.t('auth.password.invalid_token')] } }, status: :unprocessable_entity
      end
    end
  end
end
