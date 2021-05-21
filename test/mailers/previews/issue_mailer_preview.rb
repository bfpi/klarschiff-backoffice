# frozen_string_literal: true

class IssueMailerPreview < ActionMailer::Preview
  def issue
    issue_email = IssueEmail.new(issue_id: Issue.first.id, from: User.first.to_s, from_email: User.first.email)
    issue_email.enable_all
    IssueMailer.issue issue_email: issue_email
  end

  def in_process
    IssueMailer.in_process to: 'test@bfpi.de', issue: Issue.first
  end

  def closed
    IssueMailer.closed to: 'test@bfpi.de', issue: Issue.first
  end

  def delegation
    IssueMailer.delegation to: 'test@bfpi.de', issues: Issue.all.limit(5)
  end

  def inform_editorial_staff
    IssueMailer.inform_editorial_staff to: 'test@bfpi.de', issues: Issue.all.limit(3)
  end
end
