# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :auth, as: :user do
    resource :session, only: [], path: '' do
      get    :new,     path: 'login', as: 'new'
      post   :create,  path: 'login'
      delete :destroy, path: 'logout', as: 'destroy'
    end

    resource :registration, only: [], path: '' do
      get    :new,     path: 'register', as: 'new'
      post   :create,  path: 'register'
    end

    resource :password, only: [], path: '' do
      get    :new,     path: 'forgot_password', as: 'new'
      post   :create,  path: 'forgot_password'
      get    :edit,    path: 'reset_password', as: 'edit'
      put    :update,  path: 'reset_password'
    end

    resource :confirmation, only: [], path: '' do
      get    :show,    path: 'confirm_email'
    end
  end

  root to: 'posts#index'
  get 'posts', to: 'posts#index'
end

#
#  # Password routes for Recoverable, if User model has :recoverable configured
#      new_user_password GET    /users/password/new(.:format)     {controller:"devise/passwords", action:"new"}
#     edit_user_password GET    /users/password/edit(.:format)    {controller:"devise/passwords", action:"edit"}
#          user_password PUT    /users/password(.:format)         {controller:"devise/passwords", action:"update"}
#                        POST   /users/password(.:format)         {controller:"devise/passwords", action:"create"}
#
#  # Confirmation routes for Confirmable, if User model has :confirmable configured
#  new_user_confirmation GET    /users/confirmation/new(.:format) {controller:"devise/confirmations", action:"new"}
#      user_confirmation GET    /users/confirmation(.:format)     {controller:"devise/confirmations", action:"show"}
#                        POST   /users/confirmation(.:format)     {controller:"devise/confirmations", action:"create"}

# def devise_session(mapping, controllers) #:nodoc:
#   resource :session, only: [], controller: controllers[:sessions], path: "" do
#     get   :new,     path: mapping.path_names[:sign_in],  as: "new"
#     post  :create,  path: mapping.path_names[:sign_in]
#     match :destroy, path: mapping.path_names[:sign_out], as: "destroy", via: mapping.sign_out_via
#   end
# end
#
# def devise_password(mapping, controllers) #:nodoc:
#   resource :password, only: [:new, :create, :edit, :update],
#            path: mapping.path_names[:password], controller: controllers[:passwords]
# end
#
# def devise_confirmation(mapping, controllers) #:nodoc:
#   resource :confirmation, only: [:new, :create, :show],
#            path: mapping.path_names[:confirmation], controller: controllers[:confirmations]
# end
#
# def devise_unlock(mapping, controllers) #:nodoc:
#   if mapping.to.unlock_strategy_enabled?(:email)
#     resource :unlock, only: [:new, :create, :show],
#              path: mapping.path_names[:unlock], controller: controllers[:unlocks]
#   end
# end
#
# def devise_registration(mapping, controllers) #:nodoc:
#   path_names = {
#     new: mapping.path_names[:sign_up],
#     edit: mapping.path_names[:edit],
#     cancel: mapping.path_names[:cancel]
#   }
#
#   options = {
#     only: [:new, :create, :edit, :update, :destroy],
#     path: mapping.path_names[:registration],
#     path_names: path_names,
#     controller: controllers[:registrations]
#   }
#
#   resource :registration, options do
#     get :cancel
#   end
# end
