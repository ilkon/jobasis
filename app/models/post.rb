# frozen_string_literal: true

require 'htmlentities'

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

  def parse_text!
    decoded_text = HTMLEntities.new.decode(raw_text)

    chunks = decoded_text.split('|')
    emp_candidate = AttributeStripper.strip_string(chunks[0], collapse_spaces: true, replace_newlines: true, allow_empty: true)
    words_count = emp_candidate.split(' ').count
    if words_count.positive? && words_count < 5
      employer = Employer.find_or_create_by!(name: emp_candidate)
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
