# frozen_string_literal: true

module Auth
  class RegistrationsController < BaseController
    # GET /auth/register
    def new
      @user = User.new
      @user.user_emails.build
      @user.build_user_password
    end

    # POST /auth/register
    def create
      @user = User.new(user_params)

      if @user.save
        email = @user.user_emails.first
        token = email.set_confirm_token
        Auth::Mailer.confirm_email_instruction(email.email, @user, token).deliver_now

        sign_in!(@user)
        redirect_to root_path, notice: I18n.t('auth.registration.success')
      else
        render :new
      end
    end

    private

    def user_params
      params.require(:user).permit(:name, user_emails_attributes: %i[id email], user_password_attributes: %i[password])
    end
  end
end