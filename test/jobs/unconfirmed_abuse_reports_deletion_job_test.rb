# frozen_string_literal: true

require 'test_helper'

class UnconfirmedAbuseReportsJobDeletionJobTest < ActiveJob::TestCase
  test 'that job is performable' do
    assert_nothing_raised { UnconfirmedAbuseReportsDeletionJob.perform_now }
  end
end
