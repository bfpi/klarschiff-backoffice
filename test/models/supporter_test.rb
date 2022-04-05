# frozen_string_literal: true

require 'test_helper'

class SupporterTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'send mail after create' do
    supporter = Supporter.create(issue: issue(:one), author: 'test@rostock.de')
    assert_valid supporter
    assert_enqueued_email_with(
      ConfirmationMailer, :supporter,
      args: [{ to: supporter.author, confirmation_hash: supporter.confirmation_hash, issue_id: supporter.issue_id }]
    )
  end

  test 'validate author as email' do
    supporter = Supporter.new(issue: issue(:one))
    assert_not supporter.valid?
    assert_equal [{ error: :blank }], supporter.errors.details[:author]
    supporter.author = 'abc'
    assert_not supporter.valid?
    assert_equal [{ error: :email, value: 'abc' }], supporter.errors.details[:author]
    supporter.author = 'abc@example.com'
    supporter.valid?
    assert_empty supporter.errors.details[:author]
  end
end
