# frozen_string_literal: true

namespace :vacancies do
  desc 'Parse all vacancies'
  task :parse_all, %i[] => :environment do
    Rails.logger = Logger.new($stdout)

    publisher = Publisher.find_by!(name: 'HackerNews')

    posts = Post.where('publisher_id = ? AND vacancy = ?', publisher.id, true)

    posts.each do |post|
      Parse::BaseJob.perform_now(post)
    end
  end

  desc 'Parse new vacancies'
  task :parse_new, %i[] => :environment do
    Rails.logger = Logger.new($stdout)

    publisher = Publisher.find_by!(name: 'HackerNews')

    posts = Post.where('publisher_id = ? AND vacancy = ? AND (last_parsed_at IS NULL OR last_parsed_at < last_fetched_at)', publisher.id, true)

    posts.each do |post|
      Parse::BaseJob.perform_now(post)
    end
  end
end
