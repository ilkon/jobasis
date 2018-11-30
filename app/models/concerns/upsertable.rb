# frozen_string_literal: true

module Upsertable
  def self.included(base)
    base.class_eval do
      def self.upsert(key, data)
        created_at = { created_at: Time.now.utc }
        updated_at = { updated_at: Time.now.utc }
        attributes = key.merge(data).merge(created_at).merge(updated_at)

        query = "
            INSERT INTO #{table_name} (#{attributes.keys.join(', ')})
            VALUES (#{attributes.keys.map { |k| ":#{k}" }.join(', ')})
            ON CONFLICT (#{key.keys.join(', ')})
            DO UPDATE SET #{data.merge(updated_at).keys.map { |k| "#{k} = EXCLUDED.#{k}" }.join(', ')}"

        connection.execute(sanitize_sql([query, attributes]))
      end
    end
  end
end
