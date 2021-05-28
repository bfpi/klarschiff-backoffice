# frozen_string_literal: true

require 'test_helper'

class AbuseReportTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'send mail after create' do
    report = AbuseReport.create(issue: issue(:one), author: 'test@rostock.de', message: 'Test')
    assert report.valid?
    assert_enqueued_email_with(
      ConfirmationMailer, :abuse_report,
      args: [{ to: report.author, confirmation_hash: report.confirmation_hash, issue_id: report.issue_id }]
    )
  end

  test 'respond_to resolved_at?' do
    assert_respond_to abuse_report(:one), :resolved_at?
  end
end
