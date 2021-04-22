# frozen_string_literal: true

class Authority < ApplicationRecord
  belongs_to :county

  has_many :groups, class_name: 'AuthorityGroup', foreign_key: :reference_id, inverse_of: :authority,
                    dependent: :destroy
  has_many :responsibilities, through: :groups

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: { scope: :county }
end
