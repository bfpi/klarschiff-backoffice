# frozen_string_literal: true

class District < ApplicationRecord
  belongs_to :authority

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: { scope: :authority }

  def self.authorized(user = Current.user)
    if user&.role_admin?
      all
    elsif user&.role_regional_admin?
      where(authority: Authority.authorized(user).select(:id))
    else
      none
    end
  end

  def to_s
    name
  end

  alias logging_subject_name to_s

  def as_json(_options = {})
    { value: id, label: to_s }
  end
end
