# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include Auth::Authenticate
    before_action :admin_authenticate!

    private

    def admin_authenticate!
      return true if admin_signed_in?

      head :forbidden
    end

    def admin_signed_in?
      user = session[:user_id]
      user.present? && user.user_role.try(:admin)
    end

    def frontend_list_opts
      opts = {}

      if params[:pagination].present?
        pagination = JSON.parse(params[:pagination], symbolize_names: true)
        if pagination[:perPage].present?
          page = pagination[:page].to_i
          opts[:limit] = pagination[:perPage].to_i
          opts[:offset] = (page - 1) * opts[:limit]
        end
      end

      if params[:sort].present?
        sort = JSON.parse(params[:sort], symbolize_names: true)
        if sort[:field].present?
          opts[:sort_field] = sort[:field].downcase
          opts[:sort_order] = sort[:order].present? && sort[:order].casecmp('asc').zero? ? 'asc' : 'desc'
        end
      end

      if params[:filter].present?
        filter = JSON.parse(params[:filter], symbolize_names: true)
        filter.each do |key, value|
          if key == :q && value.present?
            opts[:search_string] = "%#{value}%".downcase
          else
            opts[key] = value
          end
        end
      end

      opts
    end
  end
end
