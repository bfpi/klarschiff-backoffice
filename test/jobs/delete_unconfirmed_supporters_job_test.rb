# frozen_string_literal: true

require 'test_helper'

class DeleteUnconfirmedSupportersJobTesi < ActiveJob::TestCase
  test 'that job is performable' do
    assert_nothing_raised { DeleteUnconfirmedSupportersJob.perform_now }
  end
end
