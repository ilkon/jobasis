# frozen_string_literal: true

require_relative 'string_boolean'

MAX_AGE_FOR_STASH = 4.months

namespace :hacker_news do
  desc 'Process fetched stashes'
  task :process, %i[] => :environment do
    Rails.logger = Logger.new(STDOUT)

    publisher = Publisher.find_or_create_by!(name: 'HackerNews')

    stashes = PublisherStash.where(publisher_id: publisher.id)
    if stashes.empty?
      response = Fetchers::HackerNews.fetch(Fetchers::HackerNews::ROOT_PUBLISHER_KEY)
      next unless response

      Fetchers::HackerNews.save(publisher.id, Fetchers::HackerNews::ROOT_PUBLISHER_KEY, response)
    else
      post_publisher_keys = Post.where(publisher_id: publisher.id).pluck(:publisher_key)
      publisher_keys = stashes.map(&:publisher_key) + post_publisher_keys

      stashes.each do |stash|
        next unless stash.last_processed_at.nil? || stash.last_processed_at < stash.last_fetched_at
        next if stash.publisher_key != Fetchers::HackerNews::ROOT_PUBLISHER_KEY && stash.published_at < Date.today - MAX_AGE_FOR_STASH

        stash.content.each do |publisher_key|
          next if publisher_keys.include?(publisher_key.to_s)

          response = Fetchers::HackerNews.fetch(publisher_key)
          next unless response

          next if stash.publisher_key == Fetchers::HackerNews::ROOT_PUBLISHER_KEY && response[:type] != 'story'
          next if stash.publisher_key != Fetchers::HackerNews::ROOT_PUBLISHER_KEY && response[:type] != 'comment'

          Fetchers::HackerNews.save(publisher.id, publisher_key, response)
        end

        stash.update(last_processed_at: Time.now)
      end
    end
  end

  desc 'Update fetched stashes'
  task :update, %i[] => :environment do
    Rails.logger = Logger.new(STDOUT)

    today = Date.today
    publisher = Publisher.find_or_create_by!(name: 'HackerNews')

    stashes = PublisherStash.where(publisher_id: publisher.id)
    stashes.each do |stash|
      update = if stash.publisher_key == Fetchers::HackerNews::ROOT_PUBLISHER_KEY
                 today == today.beginning_of_month
               elsif stash.published_at
                 next if stash.published_at < Date.today - MAX_AGE_FOR_STASH

                 published_ago = today - stash.published_at.to_date
                 last_fetched_ago = today - stash.last_fetched_at.to_date
                 last_fetched_ago.to_i >= published_ago.to_i / 30
               end

      next unless update

      response = Fetchers::HackerNews.fetch(stash.publisher_key)
      next unless response

      Fetchers::HackerNews.save(publisher.id, stash.publisher_key, response)
    end
  end
end
