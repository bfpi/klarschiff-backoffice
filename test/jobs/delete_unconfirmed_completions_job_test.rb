# frozen_string_literal: true

require 'test_helper'

class DeleteUnconfirmedCompletionsJobTest < ActiveJob::TestCase
  test 'that job is performable' do
    assert_nothing_raised { DeleteUnconfirmedCompletionsJob.perform_now }
  end
end
