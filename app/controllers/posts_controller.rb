# frozen_string_literal: true

class PostsController < ApplicationController
  PER_PAGE = 10

  def index
    limit = params[:per_page].to_i
    limit = PER_PAGE if limit.zero?
    offset = params[:page].to_i.positive? && (params[:page].to_i - 1) * limit || 0

    posts = Post.select('*, count(*) OVER() AS total_count')
                .includes(:employer)
                .limit(limit)
                .offset(offset)
                .order(published_at: :desc)
    total_count = posts.first&.total_count || 0

    @posts = posts.map do |p|
      {
        id:           p.id,
        raw_text:     p.raw_text,
        published_at: p.published_at.to_s,
        employer:     {
          id:   p.employer_id,
          name: p.employer.try(:name)
        }
      }
    end

    @total_pages = (total_count + limit - 1) / limit
    @current_page = offset / limit + 1

    if @current_page < 1
      @current_page = 0
    elsif @current_page > @total_pages
      @current_page = @total_pages + 1
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: { data: { posts: @posts, page: @current_page } } }
    end
  end
end
