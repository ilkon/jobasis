# frozen_string_literal: true

module Authenticatable
  def self.included(base)
    base.class_eval do
      prepend_before_action :validate_user_session

      private

      def validate_user_session
        return unless session[:user_id] || session[:user_name]

        unless session[:login_at]
          reset_session
          return
        end

        now = Time.now.to_i

        if session[:oauth_provider]
          oauth_provider_checked_at = session[:last_auth_check_at] || session[:login_at]
          if oauth_provider_checked_at + 5.minutes.to_i < now
            user = User.find_by(id: session[:user_id])
            unless user
              reset_session
              return
            end

            unless session[:oauth_access_token]
              reset_session
              return
            end

            case session[:oauth_provider].to_sym
            when :github
              userinfo = Auth::Api::Github.userinfo(session[:oauth_access_token])

              unless userinfo
                reset_session
                return
              end

              provider_id = UserSocialProfile::PROVIDERS[:github]
              uid = userinfo[:id]
              social_profile = UserSocialProfile.find_by(provider_id:, uid:)

              unless social_profile && social_profile.user_id == user.id
                reset_session
                return
              end

            else
              reset_session
              return
            end

            session[:last_auth_check_at] = now
          end

        else
          password_checked_at = session[:last_auth_check_at] || session[:login_at]
          if password_checked_at + 5.minutes.to_i < now
            user = User.find_by(id: session[:user_id])
            unless user
              reset_session
              return
            end

            if user.user_password&.changed_at && user.user_password.changed_at > password_checked_at
              reset_session
              redirect_to auth_login_path, notice: I18n.t('auth.session.changed_password')
              return
            end

            session[:last_auth_check_at] = now
          end

          visited_at = session[:last_visit_at] || session[:login_at]
          if visited_at + 30.minutes.to_i < now
            if session[:remember_me]
              if session[:login_at] + 90.days.to_i < now
                reset_session
                redirect_to auth_login_path, notice: I18n.t('auth.session.expired_session')
                return
              end
            else
              reset_session
              redirect_to auth_login_path, notice: I18n.t('auth.session.expired_session')
              return
            end
          end
        end

        session[:last_visit_at] = now
      end
    end
  end
end
