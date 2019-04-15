# frozen_string_literal: true

module Auth
  class RegistrationsController < BaseController
    # POST /auth/register
    def create
      register_params = params.permit(:email, :password, :name)

      user = User.new(
        name:                     register_params[:name],
        user_password_attributes: {
          password: register_params[:password]
        },
        user_emails_attributes:   [
          {
            email: register_params[:email]
          }
        ]
      )

      if user.save
        email = user.user_emails.first
        token = email.set_confirm_token
        Auth::Mailer.confirm_email_instruction(email.email, user, token).deliver_later

        sign_in!(user)
        redirect_to root_path, notice: I18n.t('auth.registration.success')

      else
        @values = register_params.to_h.select { |k, _v| %i[email name].include?(k.to_sym) }
        @errors = {
          email:    user.errors[:'user_emails.email'].first,
          password: user.errors[:'user_password.password'].first,
          name:     user.errors[:name].first
        }

        render :new
      end
    end
  end
end
