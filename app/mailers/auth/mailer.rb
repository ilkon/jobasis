# frozen_string_literal: true

module Auth
  class Mailer < ApplicationMailer
    def confirm_email_instruction(email, user, token)
      @user = user
      @token = token

      mail to: email, subject: I18n.t('auth.mailer.confirm_email_instruction.subject')
    end

    def reset_password_instruction(email, user, token)
      @user = user
      @token = token

      mail to: email, subject: I18n.t('auth.mailer.reset_password_instruction.subject')
    end

    def changed_password_notification(email, user)
      @user = user

      mail to: email, subject: I18n.t('auth.mailer.changed_password_notification.subject')
    end
  end
end
