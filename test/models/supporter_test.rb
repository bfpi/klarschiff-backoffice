# frozen_string_literal: true

require 'test_helper'

class SupporterTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'send mail after create' do
    supporter = Supporter.create(issue: issue(:one), author: 'test@rostock.de')
    assert supporter.valid?
    assert_enqueued_email_with(
      ConfirmationMailer, :supporter,
      args: [{ to: supporter.author, confirmation_hash: supporter.confirmation_hash, issue_id: supporter.issue_id }]
    )
  end
end
