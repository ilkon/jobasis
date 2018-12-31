# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'posts#index'
  get 'posts', to: 'posts#index'
end
