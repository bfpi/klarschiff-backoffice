# frozen_string_literal: true

class Responsibility < ApplicationRecord
  belongs_to :category
  belongs_to :group

  validate :only_one_group_for_group_type

  def self.default_scope
    type = Group.arel_table[:type]
    joins(:group).order type.eq('InstanceGroup'), type.eq('CountyGroup'), type.eq('AuthorityGroup')
  end

  private

  def only_one_group_for_group_type
    filter = { category: category, group: { type: group.type } }
    errors.add :base, :group_type_taken if self.class.joins(:group).exists?(filter)
  end
end
