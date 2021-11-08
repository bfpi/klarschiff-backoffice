# frozen_string_literal: true

module ApplicationHelper
  def l(object, **options)
    return nil unless object
    super
  end

  def icon(color, kind: 'blank')
    "icons/list/png/#{kind}-#{color}-22px.png"
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
