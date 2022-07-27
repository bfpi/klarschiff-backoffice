# frozen_string_literal: true

require 'test_helper'

class NotifyOnGroupAssignedResponsibilityJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup { ActionMailer::Base.deliveries.clear }

  test 'performable and mails get sent' do
    issues = [issue(:received_not_accepted_two)]
    group = group(:internal2)
    recipients = group.responsibility_notification_recipients
    assert_emails 1 do
      assert_nothing_raised { NotifyOnGroupAssignedResponsibilityJob.perform_now }
      assert_in_delta issues.first.reload.group_responsibility_notified_at.to_i, Time.current.to_i, 2
    end
    assert_performed_with(
      job: ActionMailer::MailDeliveryJob,
      args: ['ResponsibilityMailer', 'remind_group', 'deliver_now',
             { args: [group, { to: recipients, issues: }] }]
    )
  end
end
