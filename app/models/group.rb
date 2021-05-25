# frozen_string_literal: true

class Group < ApplicationRecord
  include Logging

  enum kind: { internal: 0, external: 1, field_service_team: 2 }, _prefix: true

  belongs_to :main_user, class_name: 'User', optional: Settings::Group.main_user_optional

  has_many :jobs, dependent: :destroy
  has_many :responsibilities, dependent: :destroy

  with_options after_add: :log_habtm_add, after_remove: :log_habtm_remove do
    has_and_belongs_to_many :field_service_operators, class_name: 'User',
                                                      join_table: :field_service_team_operator,
                                                      association_foreign_key: :operator_id,
                                                      foreign_key: :field_service_team_id
    has_and_belongs_to_many :users
  end

  validates :name, presence: true
  validates :email, presence: true, if: -> { main_user_id.blank? }
  validates :email, uniqueness: true, allow_blank: true

  scope :active, -> { where active: true }

  def self.authorized(user = Current.user)
    if user&.role_admin?
      active
    elsif user&.role_regional_admin?
      where id: user.groups.map { |gr| Group.where(type: gr.type, reference_id: gr.reference_id) }.flatten.map(&:id)
    else
      none
    end
  end

  def to_s
    short_name || name
  end

  def as_json(_options = {})
    { value: id, label: to_s }
  end
end
