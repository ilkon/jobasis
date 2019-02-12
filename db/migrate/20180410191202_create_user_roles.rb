# frozen_string_literal: true

class CreateUserRoles < ActiveRecord::Migration[5.2]
  def change
    table_name = 'user_roles'

    create_table table_name do |t|
      t.references  :user, null: false, index: { unique: true, name: "#{table_name}_user_id" }
      t.boolean     :admin, default: false

      t.timestamps
    end

    add_foreign_key table_name, :users, column: :user_id, on_delete: :cascade
  end
end
