# frozen_string_literal: true

class PagesController < ApplicationController
  def trends
    @filters = filter_params

    conditions = []
    conditions << 'V.remoteness != 2' if @filters[:remote] && !@filters[:onsite]
    conditions << 'V.remoteness != 1' if !@filters[:remote] && @filters[:onsite]
    conditions << 'V.involvement != 2' if @filters[:fulltime] && !@filters[:parttime]
    conditions << 'V.involvement != 1' if !@filters[:fulltime] && @filters[:parttime]

    sql = "
      SELECT S.id, min(S.name) AS name, to_char(V.date, 'YYYY-MM') AS date, count(*) AS vacancies_count
      FROM #{Skill.table_name} S
          JOIN #{Vacancy.table_name} V on V.skill_ids @> S.id::text::jsonb
      #{conditions.present? ? "WHERE #{conditions.join(' AND ')}" : ''}
      GROUP BY S.id, to_char(V.date, 'YYYY-MM')"
    rows = Vacancy.connection.select_all(sql)
    @skills = rows.group_by { |r| r['name'] }.sort.to_h.values
    @dates = rows.group_by { |r| r['date'] }.keys.sort
  end
end
