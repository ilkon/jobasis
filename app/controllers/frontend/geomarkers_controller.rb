# frozen_string_literal: true

module Frontend
  class GeomarkersController < ApplicationController
    def index
      unless %w[zoom].any? { |p| params[p].present? }
        render json: { errors: 'Missing parameter' }, status: :unprocessable_entity
        return
      end

      render json: Geomarker.list(params), root: :data
    end

    def init_location
      geoip = MAXMIND_DB.lookup(request.remote_ip)
      render json: { data: { lat: geoip.location.latitude, lng: geoip.location.longitude } }
      # render json: { data: { lat: 43.7, lng: -79.4 } }
    end
  end
end
