# frozen_string_literal: true

class Vacancy < ApplicationRecord
  include Partitionable

  REMOTENESS = %i[remote onsite].freeze
  INVOLVEMENT = %i[fulltime parttime].freeze

  belongs_to :publisher
  belongs_to :post
  belongs_to :employer, optional: true

  validates :published_at, presence: true
  validates :date, presence: true
  validates :text, presence: true

  serialize :skill_ids, coder: ObjectToJsonbSerializer
  serialize :urls, coder: ObjectToJsonbSerializer
  serialize :emails, coder: ObjectToJsonbSerializer

  class << self
    def create_indexes(schema, table)
      connection.execute("ALTER TABLE #{schema}.#{table} ADD PRIMARY KEY (id)")
      connection.execute("CREATE INDEX #{table}_publisher_id ON #{schema}.#{table} (publisher_id)")
      connection.execute("CREATE INDEX #{table}_post_id ON #{schema}.#{table} (post_id)")
      connection.execute("CREATE INDEX #{table}_employer_id ON #{schema}.#{table} (employer_id)")
      connection.execute("CREATE INDEX #{table}_skill_ids ON #{schema}.#{table} USING GIN (skill_ids jsonb_path_ops)")
    end
  end

  def clean_text(logged_in)
    clean_text = text.dup

    urls.each_with_index do |url, i|
      clean_text.gsub!("###URL#{i}###", url)
    end

    if logged_in
      emails.each_with_index do |email, i|
        clean_text.gsub!("###EMAIL#{i}###", email)
      end

    else
      email_placeholder = "<span class='tag is-placeholder tooltip' data-tooltip='#{I18n.t('vacancies.email_placeholder.title')}'>" \
                          "#{I18n.t('vacancies.email_placeholder.text')}</span>"
      clean_text.gsub!(/###EMAIL\d+###/, email_placeholder)
    end

    clean_text.gsub!('<a ', '<a rel="nofollow" ')

    clean_text
  end
end
