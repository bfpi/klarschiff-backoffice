# frozen_string_literal: true

require 'test_helper'

class DeleteUnconfirmedIssuesJobTest < ActiveJob::TestCase
  test 'that job is performable' do
    assert_includes issues.map(&:id), issue(:unconfirmed_with_auth_code).id
    assert_difference 'issues.count', -1 do
      assert_nothing_raised { DeleteUnconfirmedIssuesJob.perform_now }
    end
    assert_not_includes issues.map(&:id), issue(:unconfirmed_with_auth_code).id
  end

  private

  def issues
    time = JobSettings::Issue.deletion_deadline_days.days.ago
    Issue.where(issue_arel_table[:status].eq('pending').and(issue_arel_table[:created_at].lt(time)))
  end

  def issue_arel_table
    Issue.arel_table
  end
end
