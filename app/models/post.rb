# frozen_string_literal: true

class Post < ApplicationRecord
  include Partitionable

  belongs_to :publisher
  belongs_to :employer, optional: true

  validates :publisher, presence: true
  validates :publisher_key, presence: true, uniqueness: { scope: :publisher_id }
  validates :published_at, presence: true

  validates :raw_text, presence: true
  validates :date, presence: true

  serialize :features, ObjectToJsonbSerializer

  def parse!
    parsed = Parsers.HackerNews.parse(raw_text)

    if parsed[:employer_name]
      employer = Employer.find_or_create_by!(name: parsed[:employer_name])
      self.employer_id = employer.id
    end

    self.last_parsed_at = Time.now.utc
    save!
  end

  class << self
    def create_indexes(schema, table)
      connection.execute("CREATE UNIQUE INDEX #{table}_publisher ON #{schema}.#{table} (publisher_id, publisher_key)")
      connection.execute("CREATE INDEX #{table}_employer_id ON #{schema}.#{table} (employer_id)")
    end
  end
end
