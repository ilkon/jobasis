# frozen_string_literal: true

class CreateTechnologies < ActiveRecord::Migration[5.2]
  def change
    table_name = 'technologies'

    create_table table_name do |t|
      t.string :name, null: false, index: { unique: true, name: "#{table_name}_name" }
      t.jsonb  :synonyms, null: false, default: []

      t.timestamps
    end
  end
end
