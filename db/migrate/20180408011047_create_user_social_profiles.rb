# frozen_string_literal: true

class CreateUserSocialProfiles < ActiveRecord::Migration[5.2]
  def change
    table_name = 'user_social_profiles'

    create_table table_name do |t|
      t.references  :user, null: false, index: { name: "#{table_name}_user_id" }
      t.integer     :provider_id, null: false
      t.string      :uid, null: false

      t.timestamps
    end

    add_index table_name, %i[provider_id uid], unique: true, name: "#{table_name}_unique"

    add_foreign_key table_name, :users, column: :user_id, on_delete: :cascade
  end
end
