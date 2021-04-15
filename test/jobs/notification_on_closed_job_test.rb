# frozen_string_literal: true

require 'test_helper'

class NotificationOnClosedTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test 'performable and mails get sent' do
    assert_nothing_raised { NotificationOnClosedJob.perform_now }
    issue = issue(:closed)
    assert_enqueued_email_with(IssueMailer, :closed, args: [{ to: issue.author, issue: issue }])
  end
end
