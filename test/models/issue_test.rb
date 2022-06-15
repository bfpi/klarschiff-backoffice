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
    assert_no_changes 'issue.updated_by_user' do
      assert_no_changes 'issue.status' do
        issue.group = group(:two)
        assert issue.group_id_changed?
        assert_not_empty issue.group.responsibility_notification_recipients
        assert_changes 'issue.group_responsibility_notified_at' do
          assert issue.save
        end
        assert_in_delta issue.reload.group_responsibility_notified_at, Time.current, 2
      end
    end
    travel_to(time = 2.weeks.from_now) do
      assert_no_changes 'issue.updated_by_user' do
        assert_no_changes 'issue.status' do
          issue.responsibility_action = :reject
          issue.group = group(:no_users_and_email)
          assert_empty issue.group.responsibility_notification_recipients
          assert_changes 'issue.group_responsibility_notified_at' do
            assert issue.save
          end
          assert_in_delta issue.reload.group_responsibility_notified_at, time, 2
        end
      end
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

  test 'validate author as email' do
    issue = Issue.new
    assert_not issue.valid?
    assert_equal [{ error: :blank }], issue.errors.details[:author]
    issue.author = 'abc'
    assert_not issue.valid?
    assert_equal [{ error: :email, value: 'abc' }], issue.errors.details[:author]
    issue.author = 'abc@example.com'
    issue.valid?
    assert_empty issue.errors.details[:author]
  end

  test 'set_reviewed_at callback' do
    issue = issue(:received)
    assert issue.valid?
    assert_nil issue.reviewed_at
    issue.status_reviewed!
    assert_in_delta issue.reload.reviewed_at, Time.current, 2
    assert issue.status_reviewed?
  end

  test 'set_updated_by callback' do
    issue = issue(:reviewed)
    assert_no_changes 'issue.updated_by_user' do
      issue.update! description: '1, 2, 3, ... test'
    end
    Current.user = user(:admin)
    assert_changes 'issue.updated_by_user', to: Current.user do
      issue.update! description: '4, 5, 6, ... other test'
    end
  end

  test 'authorized scope' do
    assert_equal Issue.ids, Issue.authorized(user(:admin)).ids
    user = user(:regional_admin)
    assert Issue.authorized(user).any?
    assert_not_equal Issue.ids, Issue.authorized(user).ids
    assert_empty Issue.authorized(user(:editor2))
  end

  test 'ensure status not template value for responibility' do
    value = Config.for(:status_note_template, env: nil)['Zuständigkeit']
    assert_not_nil value
    assert_not_empty value
  end
end
