# frozen_string_literal: true

class IssueResponsibility < ApplicationRecord
  belongs_to :issue
  belongs_to :group

  def self.authorized(group_ids)
    IssueResponsibility.arel_table[:accepted].eq(true).and(IssueResponsibility.arel_table[:group_id].in(group_ids))
  end
end
