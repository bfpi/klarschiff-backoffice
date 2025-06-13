# frozen_string_literal: true

require 'test_helper'

class NotifyOnIssuesInProcessJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup { ActionMailer::Base.deliveries.clear }

  test 'performable and mails get sent' do
    assert_emails 0
    assert_nothing_raised { NotifyOnIssuesInProcessJob.perform_now }
    assert_emails 1
    issue = issue(:in_process)
    mail = ActionMailer::Base.deliveries.first
    assert_includes mail.to, issue.author
    assert_equal "##{issue.id}: <%= t 'enums.issue.status.in_process' %>", mail.subject
  end
end
