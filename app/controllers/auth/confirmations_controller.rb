# frozen_string_literal: true

module Auth
  class ConfirmationsController < BaseController
    # GET /auth/confirm_email?token=abcdef
    def show
      confirm_params = params.permit(:token)

      email = UserEmail.find_by_confirm_token(confirm_params[:token])

      if email
        if email.confirm_sent_at.to_i + Auth.confirm_email_token_ttl.to_i > Time.now.to_i
          email.clear_confirm_token
          sign_in!(email.user)
          @confirmed = true
        else
          flash.now[:error] = I18n.t('auth.confirmation.expired_token')
        end
      else
        flash.now[:error] = I18n.t('auth.confirmation.invalid_token')
      end
    end
  end
end
