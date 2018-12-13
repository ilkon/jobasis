# frozen_string_literal: true

require_relative 'string_boolean'

namespace :hacker_news do
  desc 'Fetch data'
  task :fetch, %i[] => :environment do
    Fetch::HackerNewsJob.perform_now
  end

  desc 'Parse posts'
  task :parse, %i[] => :environment do
    Parse::HackerNewsJob.perform_now
  end
end
