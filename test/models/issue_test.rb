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
    issue.responsibility_action = :reject
    issue.group = group(:no_users_and_email)
    assert_empty issue.group.responsibility_notification_recipients
  end
end
