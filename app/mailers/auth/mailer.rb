# frozen_string_literal: true

module Auth
  class Mailer < ApplicationMailer
    def confirm_email_instruction(email, user, token)
      @user = user
      @token = token

      mail to: email, subject: subject_for(:confirm_email_instruction)
    end

    def reset_password_instruction(email, user, token)
      @user = user
      @token = token

      mail to: email, subject: subject_for(:reset_password_instruction)
    end

    def changed_password_notification(email, user)
      @user = user

      mail to: email, subject: subject_for(:changed_password_notification)
    end

    private

    def subject_for(key)
      I18n.t("auth.mailer.#{key}.subject")
    end
  end
end
