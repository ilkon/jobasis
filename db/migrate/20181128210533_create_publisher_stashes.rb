# frozen_string_literal: true

class CreatePublisherStashes < ActiveRecord::Migration[5.2]
  def change
    table_name = 'publisher_stashes'

    create_table table_name, id: :bigserial do |t|
      t.references :publisher, null: false, index: false
      t.string     :publisher_key, null: false
      t.datetime   :published_at
      t.jsonb      :content, null: false, default: {}
      t.datetime   :last_fetched_at, null: false

      t.timestamps
    end

    add_index table_name, %i[publisher_id publisher_key], unique: true, name: "#{table_name}_unique"
  end
end
