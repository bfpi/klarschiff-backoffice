# frozen_string_literal: true

class CategoriesController < ApplicationController
  include Filter
  include Sorting

  before_action { check_auth :categories }

  helper_method :permitted_order_and_pagination_params

  def index
    @categories = filter(Category.eager_load(:main_category,
      :sub_category)).order(order_attr).page(params[:page] || 1).per(params[:per_page] || 20)
  end

  def reactivate
    @category = Category.find(params[:id])
    @category.update!(deleted_at: nil)
    redirect_to safe_redirect_params
  end

  def destroy
    @category = Category.active.find(params[:id])
    @category.update!(deleted_at: Time.current)
    redirect_to safe_redirect_params
  end

  private

  # Only allow redirection with sanitized parameters.
  def safe_redirect_params
    page = Integer(params[:page] || 1) rescue 1
    filter = (params[:filter] || {}).permit(:include_inactive, :text)
    order_by = (params[:order_by] || {}).permit(:column, :dir)
    {
      action: :index,
      page: page,
      filter: filter.to_h.slice('include_inactive', 'text'),
      order_by: order_by.to_h.slice('column', 'dir')
    }
  end

  def filter(collection)
    filter_include_inactive(super)
  end

  def permitted_order_and_pagination_params
    params.permit :page, filter: %i[include_inactive text], order_by: %i[column dir]
  end

  def default_order
    [main_category_arel_table[:kind], main_category_arel_table[:name], sub_category_arel_table[:name]]
  end
end
