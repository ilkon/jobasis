# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    table_name = 'posts'

    create_table table_name, id: :bigserial do |t|
      t.references :publisher, null: false, index: false
      t.string     :publisher_key, null: false
      t.datetime   :published_at, null: false
      t.text       :raw_text
      t.references :employer, index: false
      t.string     :author
      t.jsonb      :features, null: false, default: {}

      t.date       :date, null: false

      t.timestamps
    end
  end
end
