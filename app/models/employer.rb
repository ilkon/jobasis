# frozen_string_literal: true

class Employer < ApplicationRecord
  has_many :vacancies, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { in: 2..250 }

  strip_attributes :name
end
