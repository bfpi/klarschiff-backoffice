# frozen_string_literal: true

require 'test_helper'

class DeleteUnconfirmedAbuseReportsJobTest < ActiveJob::TestCase
  test 'that job is performable' do
    assert_nothing_raised { DeleteUnconfirmedAbuseReportsJob.perform_now }
  end
end
