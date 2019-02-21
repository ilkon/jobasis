# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :auth, as: :user do
    resource :session, only: [], path: '' do
      get    :new,     path: 'session', as: 'new'
      post   :create,  path: 'session'
      delete :destroy, path: 'session', as: 'destroy'
    end

    resource :registration, only: [], path: '' do
      get    :new,     path: 'register', as: 'new'
      post   :create,  path: 'register'
    end

    resource :password, only: [], path: '' do
      get    :new,     path: 'forgot_password', as: 'new'
      post   :create,  path: 'forgot_password'
      get    :edit,    path: 'reset_password', as: 'edit'
      post   :update,  path: 'reset_password'
    end

    get :confirm_email, to: 'emails#confirm'
  end

  root to: 'posts#index'
  get 'posts', to: 'posts#index'
end
