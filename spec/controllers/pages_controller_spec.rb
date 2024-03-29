# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController do
  describe 'GET #about' do
    it 'responds with appropriate HTTP code' do
      get :about
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #trends' do
    it 'responds with appropriate HTTP code' do
      get :trends
      expect(response).to have_http_status(:success)
    end
  end
end
