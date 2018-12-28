# frozen_string_literal: true

class PostsController < ApplicationController
  PER_PAGE = 25

  def index
    limit = params[:limit].to_i
    limit = PER_PAGE if limit.zero?
    offset = params[:offset].to_i

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
  end
end
