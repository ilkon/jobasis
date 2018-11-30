# frozen_string_literal: true

class PublisherStash < ApplicationRecord
  belongs_to :publisher

  validates :publisher, presence: true
  validates :publisher_key, presence: true, uniqueness: { scope: :publisher_id }
  validates :last_fetched_at, presence: true

  serialize :content, ObjectToJsonbSerializer
end
