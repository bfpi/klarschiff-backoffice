# frozen_string_literal: true

class IssueDelegation < ApplicationRecord
  belongs_to :issue
  belongs_to :group

  def self.authorized(group_ids)
    IssueDelegation.arel_table[:rejected].eq(false).and(IssueDelegation.arel_table[:group_id].in(group_ids))
  end

  def self.rejected
    IssueDelegation.where(IssueDelegation.arel_table[:rejected].eq(true))
  end
end
