# frozen_string_literal: true

class Responsibility < ApplicationRecord
  include DateTimeAttributesWithBooleanAccessor
  include Logging

  belongs_to :category
  belongs_to :group

  validate :only_one_group_for_group_type

  scope :active, -> { where(deleted_at: nil) }

  def self.default_scope
    type = Group.arel_table[:type]
    joins(:group).order type.eq('InstanceGroup'), type.eq('CountyGroup'), type.eq('AuthorityGroup')
  end

  alias deleted deleted_at?

  def deleted=(date_time)
    self.deleted_at = date_time.presence && Time.current
  end

  private

  def only_one_group_for_group_type
    filter = { category: category, group: { type: group.type } }
    errors.add :base, :group_type_taken if self.class.joins(:group).active.exists?(filter)
  end
end
