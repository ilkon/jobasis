# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :auth do
    get    :login,           to: 'sessions#new'
    post   :login,           to: 'sessions#create'
    delete :logout,          to: 'sessions#destroy'
    get    :register,        to: 'registrations#new'
    post   :register,        to: 'registrations#create'
    get    :forgot_password, to: 'passwords#new'
    post   :forgot_password, to: 'passwords#create'
    get    :reset_password,  to: 'passwords#edit'
    post   :reset_password,  to: 'passwords#update'
    get    :confirm_email,   to: 'emails#confirm'
    get    :github,          to: 'github#new'
    get    :github_callback, to: 'github#create'
    get    :google,          to: 'google#new'
    get    :google_callback, to: 'google#create'
  end

  root to: 'vacancies#index'
  get 'vacancies', to: 'vacancies#index'
  get 'about', to: 'pages#about'
end
