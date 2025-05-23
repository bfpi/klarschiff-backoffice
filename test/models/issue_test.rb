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
        assert_predicate issue, :group_id_changed?
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
    assert_predicate issue, :group_id_changed?
    assert_not_empty issue.group.responsibility_notification_recipients
    assert issue.save
    assert_enqueued_email_with ResponsibilityMailer, :issue, args: [
      issue, { to: issue.group.responsibility_notification_recipients }
    ]
  end

  test 'send no for group responsibility notification for groups without enabled recipients users' do
    issue = issue(:two)
    issue.group = group(:internal)
    assert_predicate issue, :group_id_changed?
    assert_not_empty issue.group.responsibility_notification_recipients
    assert_no_enqueued_emails { assert issue.save }
  end

  test 'send mail with auth_code for group responsibility notification for external groups as reference default' do
    issue = issue(:one)
    issue.group = group(:reference_default)
    assert_predicate issue, :group_id_changed?
    assert issue.save
    assert_enqueued_email_with ResponsibilityMailer, :issue, args: [
      issue, { to: issue.group.email, auth_code: AuthCode.find_by(issue_id: issue, group_id: issue.group) }
    ]
  end

  test 'send mail with auth_code without gui for group resp. notification for ext. groups as reference default' do
    issue = issue(:one)
    issue.stub :default_group_without_gui_access?, true do
      issue.group = group(:reference_default)
      assert_predicate issue, :group_id_changed?
      assert issue.save
      assert_enqueued_email_with ResponsibilityMailer, :default_group_without_gui_access, args: [
        issue, { to: issue.group.email, auth_code: AuthCode.find_by(issue_id: issue, group_id: issue.group) }
      ]
    end
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
    assert_predicate issue, :valid?
    assert_nil issue.reviewed_at
    issue.status_reviewed!
    assert_in_delta issue.reload.reviewed_at, Time.current, 2
    assert_predicate issue, :status_reviewed?
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
    assert_predicate Issue.authorized(user), :any?
    assert_not_equal Issue.ids, Issue.authorized(user).ids
    assert_empty Issue.authorized(user(:editor2))
  end

  test 'ensure status_note_template value for responibility' do
    value = Config.for(:status_note_template, env: nil)['Zuständigkeit']
    assert_not_nil value
    assert_not_empty value
  end

  test 'ensure status not changed without status_note' do
    issue = issue(:reviewed)
    issue.update status: :not_solvable, status_note: ''
    assert_not issue.valid?
    assert_equal [{ error: :blank }], issue.errors.details[:status_note]
  end

  test 'ensure status can be changed without status_note with auth_code without gui' do
    issue = issue(:reviewed)
    issue.stub :default_group_without_gui_access?, true do
      issue.update status: :not_solvable, status_note: ''
      assert_predicate issue, :valid?
    end
  end

  test 'ensure priority for responsibility' do
    issue = issue(:received_two)
    issue.send(:responsibility_recalculate!)
    assert_equal 'AuthorityGroup', issue.group.type
  end

  test 'ensure enum description_status' do
    assert_nothing_raised do
      assert_not_nil Issue.description_status_internal
    end
  end

  test 'ensure enum priority' do
    assert_nothing_raised do
      assert_not_nil Issue.priority_low
    end
  end

  test 'ensure enum status' do
    assert_nothing_raised do
      assert_not_nil Issue.status_pending
    end
  end

  test 'ensure enum trust_level' do
    assert_nothing_raised do
      assert_not_nil Issue.trust_level_internal
    end
  end

  test 'get district for issue position' do
    assert_nothing_raised do
      issue = issue(:received_two)
      assert_equal district(:one), issue.district
    end
  end
end
