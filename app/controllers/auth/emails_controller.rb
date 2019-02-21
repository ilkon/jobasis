# frozen_string_literal: true

module Auth
  class EmailsController < BaseController
    # GET /auth/confirm_email?token=abcdef
    def confirm
      confirm_params = params.permit(:token)

      email = UserEmail.find_by_confirm_token(confirm_params[:token])

      if email
        if email.confirm_sent_at.to_i + Auth.confirm_email_token_ttl.to_i > Time.now.to_i
          email.clear_confirm_token
          sign_in!(email.user)
        else
          @token_error = I18n.t('auth.email.expired_token')
        end
      else
        @token_error = I18n.t('auth.email.invalid_token')
      end
    end
  end
end
