# frozen_string_literal: true

require 'test_helper'

class DeleteUnconfirmedIssuesJobTest < ActiveJob::TestCase
  test 'that job is performable' do
    assert_nothing_raised { DeleteUnconfirmedIssuesJob.perform_now }
  end
end
