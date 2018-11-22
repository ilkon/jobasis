# frozen_string_literal: true

class CreatePublishers < ActiveRecord::Migration[5.2]
  def change
    table_name = 'publishers'

    create_table table_name do |t|
      t.string :name, null: false, index: { unique: true, name: "#{table_name}_name" }

      t.timestamps
    end
  end
end
