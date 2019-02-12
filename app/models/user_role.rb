# frozen_string_literal: true

class UserRole < ApplicationRecord
  belongs_to :user, inverse_of: :user_role

  validates :user, presence: true
end
