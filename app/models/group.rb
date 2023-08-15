# frozen_string_literal: true

class Group < ApplicationRecord
  include FullTextFilter
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

  validate :no_associated_categories, if: -> { !active && active_changed? }
  validates :name, presence: true
  validates :email, presence: true, if: -> { main_user_id.blank? && !kind_field_service_team? }

  scope :active, -> { where active: true }

  class << self
    def authorized(user = Current.user)
      return all if user&.role_admin?
      return none unless user&.role_regional_admin?
      user.groups.distinct.pluck(:type, :reference_id).map { |(t, r)| Group.where type: t, reference_id: r }
        .inject :or
    end

    def regional(lat:, lon:)
      aqtn = Authority.quoted_table_name
      cqtn = County.quoted_table_name
      gqtn = Group.quoted_table_name
      iqtn = Instance.quoted_table_name
      active.joins(<<~JOIN.squish).where(<<~SQL.squish, lat: lat.to_f, lon: lon.to_f).order(:type)
        LEFT JOIN #{aqtn} "a" ON "a"."id" = #{gqtn}."reference_id" AND #{gqtn}."type" = 'AuthorityGroup'
        LEFT JOIN #{cqtn} "c" ON "c"."id" = #{gqtn}."reference_id" AND #{gqtn}."type" = 'CountyGroup'
        LEFT JOIN #{iqtn} "i" ON "i"."id" = #{gqtn}."reference_id" AND #{gqtn}."type" = 'InstanceGroup'
      JOIN
        (ST_SetSRID(ST_MakePoint(:lon, :lat), 4326) && "a"."area") OR
        (ST_SetSRID(ST_MakePoint(:lon, :lat), 4326) && "c"."area") OR
        (ST_SetSRID(ST_MakePoint(:lon, :lat), 4326) && "i"."area")
      SQL
    end

    def by_user_region(user = Current.user)
      return all if user&.role_admin?
      user.groups.active.distinct.pluck(:type, :reference_id).map { |(t, r)| Group.where type: t, reference_id: r }
        .inject :or
    end
  end

  def to_s
    v = (short_name.presence || name).dup
    v << " (#{reference_name})" if Current.user.blank? || Current.user.role_admin?
    v
  end

  def as_json(_options = {})
    { value: id, label: to_s }
  end

  def feedback_recipient
    main_user&.email || email
  end

  def responsibility_notification_recipients
    Array.wrap(users.where(group_responsibility_recipient: true).pluck(:email).presence ||
               email.presence || main_user&.email)
  end

  private

  def reference_name
    type.remove(/Group$/).camelize.constantize.find(reference_id).to_s with_model_name: true
  end

  def full_text_content
    [name, short_name, human_enum_name(:type), human_enum_name(:kind), email].join(' ')
  end

  def no_associated_categories
    return unless Category.joins(:responsibilities).exists?(responsibility: { group_id: id })
    errors.add :base, :associated_categories
  end
end
