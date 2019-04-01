# frozen_string_literal: true

class AddTechnologyIdsToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :technology_ids, :jsonb, null: false, default: []
  end
end
