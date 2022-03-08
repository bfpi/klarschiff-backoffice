# frozen_string_literal: true

require 'test_helper'

class IssueEmailTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  { to_email: 'test@abc.de', text: 'abc' }.each do |attr, value|
    test "validate #{attr} presence" do
      issue_email = IssueEmail.new
      assert_not issue_email.valid?
      assert_equal [{ error: :blank }], issue_email.errors.details[attr]
      issue_email = IssueEmail.new(attr => value)
      issue_email.valid?
      assert_empty issue_email.errors.details[attr]
    end
  end

  %i[from_email to_email].each do |attr|
    test "validate #{attr} format" do
      value = 'trwes.sdfsdf.de'
      issue_email = IssueEmail.new(attr => value)
      assert_not issue_email.valid?
      assert_equal [{ error: :email, value: value }], issue_email.errors.details[attr]
      issue_email = IssueEmail.new(attr => 'test@abc.de')
      issue_email.valid?
      assert_empty issue_email.errors.details[attr]
    end
  end
end
