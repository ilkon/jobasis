# frozen_string_literal: true

Rails.application.config.generators do |g|
  g.template_engine :haml
  g.test_framework :rspec
  g.factory_bot dir: 'spec/factories'
end
