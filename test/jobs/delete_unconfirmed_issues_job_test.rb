# frozen_string_literal: true

require 'test_helper'

class DeleteUnconfirmedIssuesJobTest < ActiveJob::TestCase
  test 'that job is performable' do
    issues = unconfirmed_issues(JobSettings::Issue.deletion_deadline_days.days.ago)
    assert_includes issues.map(&:id), issue(:unconfirmed_with_auth_code).id
    assert_difference 'issues.count', -1 do
      assert_nothing_raised { DeleteUnconfirmedIssuesJob.perform_now }
    end
  end

  private

  def unconfirmed_issues(time)
    Issue.where(issue_arel_table[:status].eq('pending').and(issue_arel_table[:created_at].lt(time)))
  end

  def issue_arel_table
    Issue.arel_table
  end
end
