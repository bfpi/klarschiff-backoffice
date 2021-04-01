# frozen_string_literal: true

class Category < ApplicationRecord
  include Logging

  enum kind: { idea: 0, problem: 1, hint: 2 }, _prefix: true

  belongs_to :group
  has_many :parent_mapping, class_name: 'CategoryMapping', foreign_key: :child_id, inverse_of: :child,
                            dependent: :destroy
  has_many :parents, through: :parent_mapping
  has_many :child_mapping, class_name: 'CategoryMapping', foreign_key: :parent_id, inverse_of: :parent,
                           dependent: :destroy
  has_many :children, through: :child_mapping
  has_many :issues, dependent: :destroy

  validates :kind, :average_turnaround_time, presence: true

  def to_s
    name
  end
end
