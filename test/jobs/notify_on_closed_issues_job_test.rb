# frozen_string_literal: true

require 'test_helper'

class NotifyOnClosedIssuesJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test 'performable and mails get sent' do
    assert_nothing_raised { NotifyOnClosedIssuesJob.perform_now }
    issue = issue(:closed)
    assert_enqueued_email_with(IssueMailer, :closed, args: [{ to: issue.author, issue: issue }])
  end
end
