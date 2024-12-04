# frozen_string_literal: true

module Sorting
  extend ActiveSupport::Concern

  included do
    helper_method :order_params
  end

  private

  def order_params
    params.fetch(:order_by, {}).permit(%i[column dir])
  end

  def order_attr
    if respond_to?(:custom_order, true)
      custom = send(:custom_order, order_params[:column] || :id, order_dir)
      return custom if custom.present?
    end
    return [order_params[:column] || :id => order_dir] if order_params.present?
    respond_to?(:default_order, true) ? send(:default_order) : { id: :desc }
  end

  def order_dir
    order_params[:dir]&.match?(/^(a|de)sc$/i) ? order_params[:dir] : :asc
  end
end
