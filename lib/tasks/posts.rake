# frozen_string_literal: true

require_relative 'string_boolean'

namespace :posts do
  desc 'Parse texts'
  task :parse, %i[] => :environment do
    Post.where('last_parsed_at IS NULL OR last_parsed_at <= last_fetched_at').each(&:parse_text!)
  end
end
