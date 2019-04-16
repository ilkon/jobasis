# frozen_string_literal: true

# https://github.com/HackerNews/API

module Parse
  class BaseJob < ApplicationJob
    queue_as :parsers

    def perform(post)
      return if post.text.nil?

      parsed = Parsers::Base.parse(post.text)

      data = {}
      # if parsed[:employer_name]
      #   employer = Employer.find_or_create_by!(name: parsed[:employer_name])
      #   post.employer_id = employer.id
      # end

      data[:remoteness] = 0
      Vacancy::REMOTENESS.each_with_index do |f, i|
        data[:remoteness] |= (1 << i) if parsed.dig(:remoteness, f)
      end

      data[:involvement] = 0
      Vacancy::INVOLVEMENT.each_with_index do |f, i|
        data[:involvement] |= (1 << i) if parsed.dig(:involvement, f)
      end

      data[:skill_ids] = parsed[:skills].map(&:id)
      data[:urls] = parsed[:urls]
      data[:emails] = parsed[:emails]
      data[:text] = parsed[:text]

      vacancy = Vacancy.find_by(post_id: post.id)
      if vacancy
        vacancy.update(data)
      else
        key = {
          publisher_id: post.publisher_id,
          post_id:      post.id,
          published_at: post.published_at,
          date:         post.date
        }
        Vacancy.partition_model(post.date).create(key.merge(data))
      end

      post.last_parsed_at = Time.now.utc
      post.save!

      Update::BaseJob.perform_later
    end
  end
end
