# frozen_string_literal: true

require 'test_helper'

class NotifyIssuesGroupJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup { ActionMailer::Base.deliveries.clear }

  test 'performable and mails get sent' do
    assert_emails 0
    assert_nothing_raised { NotifyIssuesGroupJob.perform_now }
    assert_emails 1
    mail = ActionMailer::Base.deliveries.first
    issue = issue(:received_not_accepted_two)
    assert_includes mail.to, user(:three).email
    assert_equal "Neue Meldung ##{issue.id} in Ihrer Zuständigkeit", mail.subject
  end
end
