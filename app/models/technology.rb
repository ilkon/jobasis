# frozen_string_literal: true

class Technology < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: { in: 1..250 }

  strip_attributes :name

  serialize :synonyms, ObjectToJsonbSerializer
end
