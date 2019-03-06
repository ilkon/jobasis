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

        if session[:auth_provider]
          auth_provider_checked_at = session[:last_auth_check_at] || session[:login_at]
          if auth_provider_checked_at + Auth.auth_provider_check_session_ttl.to_i < now
            user = User.find_by(id: session[:user_id])
            unless user
              reset_session
              return
            end

            unless session[:auth_access_token]
              reset_session
              return
            end

            auth_provider = session[:auth_provider].to_sym
            auth_access_token = session[:auth_access_token]

            if auth_provider == :github
              userinfo = Auth::Api::Github.userinfo(auth_access_token)

              unless userinfo
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
          if password_checked_at + Auth.password_check_session_ttl.to_i < now
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
          if visited_at + Auth.regular_session_ttl.to_i < now
            if session[:remember_me]
              if session[:login_at] + Auth.memorized_session_ttl.to_i < now
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
