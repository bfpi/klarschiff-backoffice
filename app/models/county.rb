# frozen_string_literal: true

class County < ApplicationRecord
  has_many :groups, class_name: 'CountyGroup', foreign_key: :reference_id, inverse_of: :county, dependent: :destroy
  has_many :responsibilities, through: :groups

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: true

  def self.authorized(user = Current.user)
    return all if user&.role_admin?
    if user&.role_regional_admin?
      where id: user.groups.select(:reference_id).where(type: 'CountyGroup')
    else
      none
    end
  end

  def to_s
    name
  end
end
