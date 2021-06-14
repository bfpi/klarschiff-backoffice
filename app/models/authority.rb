# frozen_string_literal: true

class Authority < ApplicationRecord
  include RegionalScope
  include StringRepresentationWithOptionalModelName

  belongs_to :county

  has_many :groups, class_name: 'AuthorityGroup', foreign_key: :reference_id, inverse_of: :authority,
                    dependent: :destroy
  has_many :responsibilities, through: :groups

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: { scope: :county }

  def self.authorized(user = Current.user)
    return all if user&.role_admin?
    return none unless user&.role_regional_admin?
    where(id: user.groups.where(type: 'AuthorityGroup').select(:reference_id))
      .or(where(county: County.authorized(user)))
  end
end
