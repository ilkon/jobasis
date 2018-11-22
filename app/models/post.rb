# frozen_string_literal: true

class Post < ApplicationRecord
  include Partitionable

  validates_presence_of :publisher_id
  validates_presence_of :publisher_key
  validates_presence_of :published_at
  validates_presence_of :raw_text
  validates_presence_of :date

  serialize :features, ObjectToJsonbSerializer

  class << self
    def create_indexes(schema, table)
      connection.execute("CREATE INDEX #{table}_publisher_id ON #{schema}.#{table} (publisher_id)")
      connection.execute("CREATE INDEX #{table}_employer_id ON #{schema}.#{table} (employer_id)")
    end
  end
end
