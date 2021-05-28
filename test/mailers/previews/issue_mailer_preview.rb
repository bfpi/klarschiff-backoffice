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
    IssueMailer.delegation to: 'test@bfpi.de', issues: Issue.limit(5)
  end

  def inform_editorial_staff
    issues = {}
    days = {}
    %i[open_but_not_accepted in_work_without_status_note open_ideas_without_minimum_supporters created_not_in_work
       unsolvable_without_status_note reviewed_but_not_accepted without_editorial_approval].each do |key|
      issues[key] = Issue.limit(3)
      days[key] = 1
    end
    IssueMailer.inform_editorial_staff to: 'test@bfpi.de', issues: issues, days: days
  end
end
