# frozen_string_literal: true

class District < ApplicationRecord
  include Citysdk::Serialization

  belongs_to :authority

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: { conditions: -> { where authority: authority } }

  self.serialization_attributes = %i[id name grenze]

  alias_attribute :grenze, :area

  def self.authorized(user = Current.user)
    return all if user&.role_admin?
    return none unless user&.role_regional_admin?
    where authority: Authority.authorized(user).select(:id)
  end

  def to_s
    name
  end

  alias logging_subject_name to_s

  def as_json(_options = {})
    { value: id, label: to_s }
  end
end
