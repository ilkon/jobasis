# frozen_string_literal: true

class Post < ApplicationRecord
  include Partitionable

  belongs_to :publisher

  validates :publisher_key, presence: true, uniqueness: { scope: :publisher_id }
  validates :published_at, presence: true
  validates :last_fetched_at, presence: true
  validates :date, presence: true

  class << self
    def create_indexes(schema, table)
      connection.execute("ALTER TABLE #{schema}.#{table} ADD PRIMARY KEY (id)")
      connection.execute("CREATE UNIQUE INDEX #{table}_unique ON #{schema}.#{table} (publisher_id, publisher_key)")
      connection.execute("CREATE INDEX #{table}_vacancy ON #{schema}.#{table} (publisher_id, vacancy)")
    end
  end
end
