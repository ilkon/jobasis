# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include StripAttributes
  include Upsertable

  self.abstract_class = true
end
