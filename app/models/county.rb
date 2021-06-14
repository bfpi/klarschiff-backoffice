# frozen_string_literal: true

class County < ApplicationRecord
  include RegionalScope
  include StringRepresentationWithOptionalModelName

  has_many :groups, class_name: 'CountyGroup', foreign_key: :reference_id, inverse_of: :county, dependent: :destroy
  has_many :responsibilities, through: :groups

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: true

  def self.authorized(user = Current.user)
    return all if user&.role_admin?
    return none unless user&.role_regional_admin?
    where id: user.groups.where(type: 'CountyGroup').select(:reference_id)
  end
end
