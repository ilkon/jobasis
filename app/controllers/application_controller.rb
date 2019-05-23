# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authenticatable

  private

  def filter_params
    %i[remote onsite fulltime parttime skill_ids].each_with_object({}) { |p, hash| hash[p] = params[p] if params[p].present? }
  end
end
