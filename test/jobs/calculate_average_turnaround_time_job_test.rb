# frozen_string_literal: true

require 'test_helper'

class CalculateAverageTurnaroundTimeJobTest < ActiveJob::TestCase
  test 'that job is performable' do
    assert_nothing_raised { FCalculateAverageTurnaroundTimeJo.perform_now }
  end
end
