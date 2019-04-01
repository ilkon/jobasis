# frozen_string_literal: true

class Post < ApplicationRecord
  include Partitionable

  REMOTENESS = %i[remote onsite].freeze
  INVOLVEMENT = %i[fulltime parttime].freeze

  belongs_to :publisher
  belongs_to :employer, optional: true

  validates :publisher, presence: true
  validates :publisher_key, presence: true, uniqueness: { scope: :publisher_id }
  validates :published_at, presence: true

  validates :raw_text, presence: true
  validates :date, presence: true

  serialize :technology_ids, ObjectToJsonbSerializer
  serialize :features, ObjectToJsonbSerializer

  class << self
    def create_indexes(schema, table)
      connection.execute("CREATE UNIQUE INDEX #{table}_publisher ON #{schema}.#{table} (publisher_id, publisher_key)")
      connection.execute("CREATE INDEX #{table}_employer_id ON #{schema}.#{table} (employer_id)")
      connection.execute("CREATE INDEX #{table}_technology_ids ON #{schema}.#{table} USING GIN (technology_ids jsonb_path_ops)")
    end
  end
end
