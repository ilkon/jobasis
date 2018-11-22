# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    table_name = 'posts'

    create_table table_name do |t|
      t.references :publisher, null: false
      t.string :publisher_key
      t.datetime :published_at
      t.references :employer
      t.string :author
      t.text :text
      t.jsonb :features, null: false, default: {}

      t.timestamps
    end
  end
end
