# frozen_string_literal: true

class Category < ApplicationRecord
  enum kind: { idea: 0, problem: 1, hint: 2 }, _prefix: true

  belongs_to :category, optional: true
end
