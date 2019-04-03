# frozen_string_literal: true

class PostsController < ApplicationController
  PER_PAGE = 10

  def index
    limit = params[:per_page].to_i
    limit = PER_PAGE if limit.zero?
    offset = params[:page].to_i.positive? && (params[:page].to_i - 1) * limit || 0

    @posts = Post.select('*, count(*) OVER() AS total_count')
                 .includes(:employer)
                 .limit(limit)
                 .offset(offset)
                 .order(published_at: :desc).to_a
    total_count = @posts.first&.total_count || 0

    @total_pages = (total_count + limit - 1) / limit
    @current_page = offset / limit + 1

    if @current_page < 1
      @current_page = 0
    elsif @current_page > @total_pages
      @current_page = @total_pages + 1
    end

    @skills = Skill.all.each_with_object({}) { |skill, hash| hash[skill.id] = skill.name }

    @last_visit_at = session[:posts_last_visit_at]
    session[:posts_last_visit_at] = Time.now.to_i
  end
end
