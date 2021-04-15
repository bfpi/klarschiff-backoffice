# frozen_string_literal: true

require 'test_helper'

class UnconfirmedIssuesJobDeletionJobTest < ActiveJob::TestCase
  test 'that job is performable' do
    assert_nothing_raised { UnconfirmedIssuesDeletionJob.perform_now }
  end
end
