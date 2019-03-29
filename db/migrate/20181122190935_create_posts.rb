# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    table_name = 'posts'

    create_table table_name, id: :bigserial do |t|
      t.references :publisher, null: false, index: false
      t.string     :publisher_key, null: false
      t.datetime   :published_at
      t.text       :raw_text, null: false
      t.references :employer, index: false
      t.string     :author
      t.integer    :remoteness
      t.integer    :involvement
      t.jsonb      :features, null: false, default: {}
      t.datetime   :last_fetched_at, null: false
      t.datetime   :last_parsed_at

      t.date       :date, null: false

      t.timestamps
    end
  end
end
