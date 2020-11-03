# frozen_string_literal: true

class IssueMailerPreview < ActionMailer::Preview
  def issue
    IssueMailer.issue issue_email: Issue.first, body: 'mailbody'
  end
end
