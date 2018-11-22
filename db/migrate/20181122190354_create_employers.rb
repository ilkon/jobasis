# frozen_string_literal: true

class CreateEmployers < ActiveRecord::Migration[5.2]
  def change
    table_name = 'employers'

    create_table table_name do |t|
      t.string :name, null: false, index: { unique: true, name: "#{table_name}_name" }
      t.string :url

      t.timestamps
    end
  end
end
