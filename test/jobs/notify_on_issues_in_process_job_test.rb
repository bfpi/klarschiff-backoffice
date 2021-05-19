# frozen_string_literal: true

require 'test_helper'

class NotifyOnIssuesInProcessJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test 'performable and mails get sent' do
    assert_nothing_raised { NotifyOnIssuesInProcessJob.perform_now }
    issue = issue(:in_process)
    assert_enqueued_email_with(IssueMailer, :in_process, args: [{ to: issue.author, issue: issue }])
  end
end
