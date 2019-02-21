# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Frontend', type: :routing do
  it { expect(get: '/').to route_to('posts#index') }
end
