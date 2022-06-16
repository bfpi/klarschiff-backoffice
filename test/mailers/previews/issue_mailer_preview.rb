# frozen_string_literal: true

class IssueMailerPreview < ActionMailer::Preview
  def forward_issue_by_system_all_options_enabled
    issue_email = IssueEmail.new(issue_id: Issue.first.id, from: User.first.to_s, from_email: User.first.email)
    issue_email.enable_all
    IssueMailer.forward issue_email:
  end

  def forward_issue_by_user_mail_client
    issue_email = IssueEmail.new(issue_id: Issue.first.id, from: User.first.to_s, from_email: User.first.email)
    issue_email.send_map = 1
    IssueMailer.forward issue_email:
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

  def delegation_with_auth_code
    issues = Issue.limit(2)
    auth_codes = issues.map { |i| AuthCode.new group: Group.first, issue: i, uuid: SecureRandom.uuid }
    IssueMailer.delegation to: 'test@bfpi.de', issues:, auth_codes:
  end

  def inform_editorial_staff
    issues = {}
    days = {}
    %i[open_but_not_accepted in_work_without_status_note open_ideas_without_minimum_supporters created_not_in_work
       unsolvable_without_status_note reviewed_but_not_accepted without_editorial_approval].each do |key|
      issues[key] = Issue.limit(3)
      days[key] = 1
    end
    IssueMailer.inform_editorial_staff to: 'test@bfpi.de', issues:, days:
  end
end
