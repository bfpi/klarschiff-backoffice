# frozen_string_literal: true

module CategoriesHelper
  def categories_for_kind(kind)
    Category.includes(:children).where(kind: kind).map(&:children).flatten
  end
end
