# frozen_string_literal: true

class PostsController < ApplicationController
  def index
    @posts = Post.limit(10).order(published_at: :desc)
  end
end
