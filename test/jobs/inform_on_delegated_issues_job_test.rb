# frozen_string_literal: true

require 'test_helper'

class InformOnDelegatedIssuesJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test 'perform and mails get sent' do
    assert_nothing_raised { InformOnDelegatedIssuesJob.perform_now }
    assert_enqueued_email_with(
      IssueMailer, :delegation,
      args: [{ to: group(:external).user.pluck(:email), issues: Issue.where(id: issue(:delegated).id) }]
    )
  end
end
