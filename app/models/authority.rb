# frozen_string_literal: true

class Authority < ApplicationRecord
  belongs_to :county

  has_many :groups, class_name: 'AuthorityGroup', foreign_key: :reference_id, inverse_of: :authority,
                    dependent: :destroy
  has_many :responsibilities, through: :groups

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: { scope: :county }

  def self.authorized(user = Current.user)
    return all if user&.role_admin?
    if user&.role_regional_admin?
      where id: user.groups.select(:reference_id).where(type: 'AuthorityGroup')
    else
      none
    end
  end

  def to_s
    name
  end
end
