# frozen_string_literal: true

class PagesController < ApplicationController
  def insights
    sql = "
      SELECT S.id, min(S.name) AS name, to_char(V.date, 'YYYY-MM') AS date, count(*) AS vacancies_count
      FROM #{Skill.table_name} S
          JOIN #{Vacancy.table_name} V on V.skill_ids @> S.id::text::jsonb
      GROUP BY S.id, to_char(V.date, 'YYYY-MM')"
    rows = Vacancy.connection.select_all(sql)
    @skills = rows.group_by { |r| r['id'] }.values
    @dates = rows.group_by { |r| r['date'] }.keys.sort
  end
end
