# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Frontend' do
  it { expect(get: '/').to route_to('vacancies#index') }
  it { expect(get: '/vacancies').to route_to('vacancies#index') }
  it { expect(get: '/about').to route_to('pages#about') }
  it { expect(get: '/trends').to route_to('pages#trends') }
end
