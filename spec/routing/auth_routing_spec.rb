# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auth', type: :routing do
  it { expect(get:    '/auth/login').to           route_to('auth/sessions#new') }
  it { expect(post:   '/auth/login').to           route_to('auth/sessions#create') }
  it { expect(delete: '/auth/logout').to          route_to('auth/sessions#destroy') }
  it { expect(get:    '/auth/register').to        route_to('auth/registrations#new') }
  it { expect(post:   '/auth/register').to        route_to('auth/registrations#create') }
  it { expect(get:    '/auth/confirm_email').to   route_to('auth/emails#confirm') }
  it { expect(get:    '/auth/forgot_password').to route_to('auth/passwords#new') }
  it { expect(post:   '/auth/forgot_password').to route_to('auth/passwords#create') }
  it { expect(get:    '/auth/reset_password').to  route_to('auth/passwords#edit') }
  it { expect(post:   '/auth/reset_password').to  route_to('auth/passwords#update') }
end
