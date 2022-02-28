# frozen_string_literal: true

require 'test_helper'

class NotifyIssuesGroupJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup { ActionMailer::Base.deliveries.clear }

  test 'performable and mails get sent' do
    issue = issue(:received_not_accepted_two)
    recipients = issue.group.notification_recipients
    assert_emails 1 do
      assert_nothing_raised { NotifyIssuesGroupJob.perform_now }
    end
    assert_performed_with(
      job: ActionMailer::MailDeliveryJob,
      args: ['IssueMailer', 'responsibility', 'deliver_now',
             { args: [{ to: recipients, issue: issue, auth_code: auth_code(:three) }] }]
    )
  end
end
