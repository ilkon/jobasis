# frozen_string_literal: true

class Vacancy < ApplicationRecord
  include Partitionable

  REMOTENESS = %i[remote onsite].freeze
  INVOLVEMENT = %i[fulltime parttime].freeze

  belongs_to :publisher
  belongs_to :post
  belongs_to :employer, optional: true

  validates :publisher, presence: true
  validates :post, presence: true
  validates :published_at, presence: true
  validates :date, presence: true
  validates :text, presence: true

  serialize :skill_ids, ObjectToJsonbSerializer
  serialize :urls, ObjectToJsonbSerializer
  serialize :emails, ObjectToJsonbSerializer

  class << self
    def create_indexes(schema, table)
      connection.execute("CREATE INDEX #{table}_publisher_id ON #{schema}.#{table} (publisher_id)")
      connection.execute("CREATE INDEX #{table}_post_id ON #{schema}.#{table} (post_id)")
      connection.execute("CREATE INDEX #{table}_employer_id ON #{schema}.#{table} (employer_id)")
      connection.execute("CREATE INDEX #{table}_skill_ids ON #{schema}.#{table} USING GIN (skill_ids jsonb_path_ops)")
    end
  end
end
