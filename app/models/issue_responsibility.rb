# frozen_string_literal: true

class IssueResponsibility < ApplicationRecord
  belongs_to :issue
  belongs_to :group

  def self.authorized(group_ids)
    where accepted: true, group_id: group_ids
  end
end
