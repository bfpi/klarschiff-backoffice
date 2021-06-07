# frozen_string_literal: true

require 'test_helper'

class NotifyOnClosedIssuesJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test 'performable and mails get sent' do
    assert_emails 0
    assert_nothing_raised { NotifyOnClosedIssuesJob.perform_now }
    assert_emails 1
    issue = issue(:closed)
    mail = ActionMailer::Base.deliveries.first
    assert_includes mail.to, issue.author
    assert_equal "##{issue.id}: abgeschlossen", mail.subject
  end
end
