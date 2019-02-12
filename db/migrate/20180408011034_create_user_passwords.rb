# frozen_string_literal: true

class CreateUserPasswords < ActiveRecord::Migration[5.2]
  def change
    table_name = 'user_passwords'

    create_table table_name do |t|
      t.references  :user, null: false, index: { unique: true, name: "#{table_name}_user_id" }
      t.string      :encrypted_password, null: false

      t.string      :reset_token, index: { unique: true, name: "#{table_name}_reset_token" }
      t.datetime    :reset_sent_at

      t.timestamps
    end

    add_foreign_key table_name, :users, column: :user_id, on_delete: :cascade
  end
end
