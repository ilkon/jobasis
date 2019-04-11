# frozen_string_literal: true

class VacanciesController < ApplicationController
  PER_PAGE = 10

  def index
    limit = params[:per_page].to_i
    limit = PER_PAGE if limit.zero?
    offset = params[:page].to_i.positive? && (params[:page].to_i - 1) * limit || 0

    @vacancies = Vacancy.select('*, count(*) OVER() AS total_count')
                        .includes(:employer)
                        .limit(limit)
                        .offset(offset)
                        .order(published_at: :desc)

    @filters = %i[remote onsite fulltime parttime].each_with_object({}) { |p, hash| hash[p] = params[p] if params[p].present? }

    @vacancies = @vacancies.where(remoteness: [0, 1, 3]) if @filters[:remote] && !@filters[:onsite]
    @vacancies = @vacancies.where(remoteness: [0, 2, 3]) if !@filters[:remote] && @filters[:onsite]
    @vacancies = @vacancies.where(involvement: [0, 1, 3]) if @filters[:fulltime] && !@filters[:parttime]
    @vacancies = @vacancies.where(involvement: [0, 2, 3]) if !@filters[:fulltime] && @filters[:parttime]

    @vacancies = @vacancies.to_a

    total_count = @vacancies.first&.total_count || 0

    @total_pages = (total_count + limit - 1) / limit
    @current_page = offset / limit + 1

    if @current_page < 1
      @current_page = 0
    elsif @current_page > @total_pages
      @current_page = @total_pages + 1
    end

    @skills = Skill.all.each_with_object({}) { |skill, hash| hash[skill.id] = skill.name }

    @last_visit_at = session[:vacancies_last_visit_at]
    session[:vacancies_last_visit_at] = Time.now.to_i
  end
end
