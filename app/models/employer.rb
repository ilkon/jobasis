# frozen_string_literal: true

class Employer < ApplicationRecord
  has_many :posts, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { in: 2..250 }

  strip_attributes

  default_scope { order(:name) }
end
