# frozen_string_literal: true

class IssueMailerPreview < ActionMailer::Preview
  def issue
    IssueMailer.issue issue_email: Issue.first, body: 'mailbody'
  end

  def in_process
    IssueMailer.in_process(to: 'test@bfpi.de', issue: Issue.first)
  end

  def closed
    IssueMailer.closed(to: 'test@bfpi.de', issue: Issue.first)
  end

  def delegation
    IssueMailer.delegation(to: 'test@bfpi.de', issues: Issue.all)
  end
end
