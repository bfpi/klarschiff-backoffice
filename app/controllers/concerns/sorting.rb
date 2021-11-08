# frozen_string_literal: true

module Sorting
  extend ActiveSupport::Concern

  included do
    helper_method :order_link
    delegate :tag, to: 'ActionController::Base.helpers'
  end

  def order_params
    params.fetch(:order_by, {}).permit(%i[column dir])
  end

  def order_attr
    if respond_to?(:custom_order, true)
      custom = send(:custom_order, order_params[:column] || :id, order_dir)
      return custom if custom.present?
    end
    return [(order_params[:column] || :id) => order_dir] if order_params.present?
    respond_to?(:default_order, true) ? send(:default_order) : { id: :desc }
  end

  def order_dir
    order_params[:dir]&.match?(/^(a|de)sc$/i) ? order_params[:dir] : :asc
  end

  def order_link(label, controller, col)
    url = url_for(controller: controller, order_by: { column: col, dir: order_link_dir(col) })
    tag.a((label + order_dir_icon(col)).html_safe, href: url) # rubocop:disable Rails/OutputSafety
  end

  def order_dir_icon(col)
    return '' if order_params.blank? || order_params[:column].to_sym != col.to_sym
    tag.span('', class: "mx-2 fa fa-chevron-#{order_params[:dir].to_sym == :asc ? 'up' : 'down'}")
  end

  def order_link_dir(col)
    return :asc if order_params.blank? || order_params[:column].to_sym != col.to_sym
    order_params[:dir].to_sym == :asc ? :desc : :asc
  end
end
