# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 3.2'

gem 'rails', '~> 7.0'
gem 'puma'

gem 'pg'

gem 'authonomy'

gem 'ffaker'
gem 'typhoeus'

gem 'redis'
gem 'resque'
gem 'resque-pool'
gem 'whenever', require: false

gem 'sprockets-rails'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'haml-rails'
gem 'bulma-rails'
gem 'font-awesome-sass'

gem 'bootsnap', require: false

group :development do
  gem 'brakeman'
  gem 'bullet'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'web-console'
end

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webmock'
end
