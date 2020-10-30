# frozen_string_literal: true

class CategoryMapping < ApplicationRecord
  belongs_to :parent, class_name: 'Category'
  belongs_to :child, class_name: 'Category'
end
