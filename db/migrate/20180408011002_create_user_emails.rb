# frozen_string_literal: true

class CreateUserEmails < ActiveRecord::Migration[5.2]
  def change
    table_name = 'user_emails'

    create_table table_name do |t|
      t.references  :user, null: false, index: { name: "#{table_name}_user_id" }
      t.string      :email, null: false, index: { unique: true, name: "#{table_name}_email" }

      t.string      :confirm_token, index: { unique: true, name: "#{table_name}_confirm_token" }
      t.datetime    :confirm_sent_at
      t.datetime    :confirmed_at

      t.timestamps
    end

    add_foreign_key table_name, :users, column: :user_id, on_delete: :cascade
  end
end
