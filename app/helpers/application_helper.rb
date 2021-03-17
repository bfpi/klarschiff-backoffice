# frozen_string_literal: true

module ApplicationHelper
  def l(object, **options)
    return nil unless object
    super
  end

  def icon(color, kind: 'blank')
    "icons/list/png/#{kind}-#{color}-22px.png"
  end
end
