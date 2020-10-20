# frozen_string_literal: true

class Category < ApplicationRecord
  belongs_to :category, optional: true

  enum kind: { idea: 0, problem: 1, hint: 2 }, _prefix: true
end
