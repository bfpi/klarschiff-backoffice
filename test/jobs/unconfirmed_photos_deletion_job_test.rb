# frozen_string_literal: true

require 'test_helper'

class UnconfirmedPhotosJobDeletionJobTest < ActiveJob::TestCase
  test 'that job is performable' do
    assert_nothing_raised { UnconfirmedPhotosDeletionJob.perform_now }
  end
end
