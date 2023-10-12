# frozen_string_literal: true

class Responsibility < ApplicationRecord
  include DateTimeAttributesWithBooleanAccessor
  include FullTextFilter
  include Logging

  belongs_to :category
  belongs_to :group

  validate :only_one_group_for_group_type

  scope :active, -> { where(deleted_at: nil) }

  class << self
    def default_scope
      type = Group.arel_table[:type]
      joins(:group).order type.eq('InstanceGroup'), type.eq('CountyGroup'), type.eq('AuthorityGroup')
    end

    def authorized(user = Current.user)
      return all if user&.role_admin?
      return none unless user&.role_regional_admin?
      where group_id: Group.authorized(user)
    end

    def regional(lat:, lon:)
      where group_id: Group.regional(lat:, lon:)
    end
  end

  def deleted
    deleted_at?
  end

  def deleted=(date_time)
    self.deleted_at = date_time.presence && Time.current
  end

  private

  def only_one_group_for_group_type
    filter = { category:, group: filter_group }
    return unless self.class.active.joins(:group).where.not(group: { id: group_id_was }).exists?(filter)
    errors.add :base, :group_type_taken, type: group.type.constantize.model_name.human
  end

  def filter_group
    { type: group&.type, reference_id: group&.reference_id }
  end

  def full_text_content
    [category, group].join(' ')
  end
end
