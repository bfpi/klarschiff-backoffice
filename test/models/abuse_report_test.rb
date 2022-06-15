# frozen_string_literal: true

require 'test_helper'

class AbuseReportTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'send mail after create' do
    report = AbuseReport.create(issue: issue(:one), author: 'test@rostock.de', message: 'Test')
    assert_valid report
    assert_enqueued_email_with(
      ConfirmationMailer, :abuse_report,
      args: [{ to: report.author, confirmation_hash: report.confirmation_hash, issue_id: report.issue_id }]
    )
  end

  test 'respond_to resolved_at?' do
    assert_respond_to abuse_report(:one), :resolved_at?
  end

  test 'validate author as email' do
    abuse_report = AbuseReport.new
    assert_not abuse_report.valid?
    assert_equal [{ error: :blank }], abuse_report.errors.details[:author]
    abuse_report.author = 'abc'
    assert_not abuse_report.valid?
    assert_equal [{ error: :email, value: 'abc' }], abuse_report.errors.details[:author]
    abuse_report.author = 'abc@example.com'
    abuse_report.valid?
    assert_empty abuse_report.errors.details[:author]
  end
end
