# frozen_string_literal: true

require 'test_helper'

class DeleteUnconfirmedPhotosJobTest < ActiveJob::TestCase
  test 'that job is performable' do
    assert_nothing_raised { DeleteUnconfirmedPhotosJob.perform_now }
  end
end
