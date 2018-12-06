# frozen_string_literal: true

class PostsController < ApplicationController
  def index
    @posts = Post.includes(:employer).limit(100).order(published_at: :desc).map do |p|
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
  end
end
