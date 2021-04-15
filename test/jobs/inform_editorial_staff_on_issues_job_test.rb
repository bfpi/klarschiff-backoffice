# frozen_string_literal: true

require 'test_helper'

class InformEditorialStaffOnIssuesJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test 'performable' do
    assert_nothing_raised { InformEditorialStaffOnIssuesJob.perform_now }
  end
end
