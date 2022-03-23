# frozen_string_literal: true

require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'send confirmation mail after create' do
    issue = Issue.create(
      author: 'test@rostock.de', description: 'Test', category: category(:one), status: 0,
      position: 'POINT(12.104630572065371 54.07595060029302)', group: group(:internal)
    )
    assert_valid issue
    assert_enqueued_email_with(
      ConfirmationMailer, :issue,
      args: [{ to: issue.author, confirmation_hash: issue.confirmation_hash, issue_id: issue.id, with_photo: false }]
    )
  end

  test 'respond_to archived_at?' do
    assert_respond_to issue(:one), :archived_at?
  end

  test 'respond_to archived' do
    assert_respond_to issue(:one), :archived
  end

  test 'respond_to reviewed_at?' do
    assert_respond_to issue(:one), :reviewed_at?
  end

  test 'group_responsibility_notified_at' do
    issue = issue(:one)
    assert_not_nil issue.group_responsibility_notified_at
    issue.group = group(:two)
    assert issue.group_id_changed?
    assert_not_empty issue.group.responsibility_notification_recipients
    assert_changes 'issue.group_responsibility_notified_at' do
      assert issue.save
    end
    assert_in_delta issue.reload.group_responsibility_notified_at, Time.current, 2
    travel_to (time = Time.current + 2.weeks) do
      issue.responsibility_action = :reject
      issue.group = group(:no_users_and_email)
      assert_empty issue.group.responsibility_notification_recipients
      assert_changes 'issue.group_responsibility_notified_at' do
        assert issue.save
      end
      assert_in_delta issue.reload.group_responsibility_notified_at, time, 2
    end
  end

  test 'send mail for group responsibility notification for groups with enabled recipients users' do
    issue = issue(:one)
    issue.group = group(:internal2)
    assert issue.group_id_changed?
    assert_not_empty issue.group.responsibility_notification_recipients
    assert issue.save
    assert_enqueued_email_with ResponsibilityMailer, :issue, args: [
      issue, { to: issue.group.responsibility_notification_recipients }
    ]
  end

  test 'send no for group responsibility notification for groups without enabled recipients users' do
    issue = issue(:two)
    issue.group = group(:internal)
    assert issue.group_id_changed?
    assert_not_empty issue.group.responsibility_notification_recipients
    assert_no_enqueued_emails { assert issue.save }
  end

  test 'send mail with auth_code for group responsibility notification for external groups as reference default' do
    issue = issue(:one)
    issue.group = group(:reference_default)
    assert issue.group_id_changed?
    assert issue.save
    assert_enqueued_email_with ResponsibilityMailer, :issue, args: [
      issue, { to: issue.group.email, auth_code: AuthCode.find_by(issue_id: issue, group_id: issue.group) }
    ]
  end
end
