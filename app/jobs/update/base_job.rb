# frozen_string_literal: true

# https://github.com/HackerNews/API

require 'redis'
require 'resque-loner'

module Update
  class BaseJob < ApplicationJob
    include Resque::Plugins::UniqueJob

    queue_as :updaters

    SKILLS_EXPIRE_TTL = 30 * 24 * 60 * 60 # 30 days
    SKILLS_TIME_WINDOW = 30.days
    SKILLS_REDIS_KEY = 'remotico:skills'

    def perform
      date = Date.today - SKILLS_TIME_WINDOW
      vacancies = Vacancy.where('published_at > ?', date)

      skills = {}
      vacancies.each do |vacancy|
        vacancy.skill_ids.each do |skill_id|
          skills[skill_id] ||= 0
          skills[skill_id] += 1
        end
      end

      redis = Redis.new

      redis.set(SKILLS_REDIS_KEY, skills.to_json)
      redis.expire(SKILLS_REDIS_KEY, SKILLS_EXPIRE_TTL)
    end
  end
end
