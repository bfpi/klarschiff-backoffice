# frozen_string_literal: true

require 'test_helper'

class CompletionTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'confirming completion closes issue' do
    completion = completion(:one)
    assert_not (issue = completion.issue).status_closed?
    completion.update!(confirmed_at: Time.current)
    assert_predicate issue, :status_closed?
  end

  test 'confirming rejected completion withoud closing issue' do
    completion = completion(:rejected)
    completion.update(confirmed_at: Time.current)
    assert_not completion.valid?
    assert_equal [{ error: :blank }], completion.errors.details[:notice]
    assert_not_predicate completion, :status_closed?
  end

  test 'rejection restores old issue status and triggers mailer' do
    completion = completion(:confirmed)
    assert_predicate completion, :status_open?
    assert_predicate (issue = completion.issue), :status_closed?
    assert issue.valid?
    assert_predicate (author = completion.author), :present?
    completion.reject_with_status_reset = true
    assert_enqueued_email_with(CompletionMailer, :rejection, args: [{ to: author, completion: }]) do
      assert completion.update(status: 'rejected', notice: 'test')
    end
    assert_predicate completion.reload, :status_rejected?
    assert_nil completion.author
    assert_predicate issue.reload, :status_reviewed?
  end

  test 'reject completion after confirming completion for closed issue with closed completion' do
    completion = completion(:unconfirmed)
    assert_predicate completion, :status_open?
    assert_predicate (issue = completion.issue), :status_closed?
    completion.update!(confirmed_at: Time.current)
    assert_predicate completion.reload, :status_rejected?
    assert_predicate issue.reload, :status_closed?
  end

  test 'validate author as email' do
    completion = Completion.new
    assert_not completion.valid?
    assert_equal [{ error: :blank }], completion.errors.details[:author]
    completion.author = 'abc'
    assert_not completion.valid?
    assert_equal [{ error: :email, value: 'abc' }], completion.errors.details[:author]
    completion.author = 'abc@example.com'
    completion.valid?
    assert_empty completion.errors.details[:author]
  end
end
