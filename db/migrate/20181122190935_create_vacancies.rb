# frozen_string_literal: true

class CreateVacancies < ActiveRecord::Migration[5.2]
  def change
    table_name = 'vacancies'

    create_table table_name, id: :bigserial do |t|
      t.references :publisher, null: false, index: false
      t.references :post, null: false, index: false
      t.datetime   :published_at, null: false
      t.references :employer, index: false
      t.integer    :remoteness
      t.integer    :involvement
      t.jsonb      :skill_ids, null: false, default: []
      t.jsonb      :features, null: false, default: {}

      t.date       :date, null: false

      t.timestamps
    end
  end
end
