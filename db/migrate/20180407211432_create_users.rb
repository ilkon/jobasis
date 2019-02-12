# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    table_name = 'users'

    create_table table_name do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
