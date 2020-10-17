# frozen_string_literal: true

namespace :posts do
  desc 'Fetch posts'
  task :fetch, %i[] => :environment do
    Rails.logger = Logger.new($stdout)

    Fetch::HackerNewsJob.perform_now
  end
end
