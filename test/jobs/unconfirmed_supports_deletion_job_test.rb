# frozen_string_literal: true

require 'test_helper'

class UnconfirmedSupportsJobDeletionJobTest < ActiveJob::TestCase
  test 'that job is performable' do
    assert_nothing_raised { UnconfirmedSupportsDeletionJob.perform_now }
  end
end
