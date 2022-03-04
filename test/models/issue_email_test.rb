# frozen_string_literal: true

require 'test_helper'

class IssueEmailTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  %i[to_email text].each do |attr|
    test "validate #{attr} presence" do
      issue_email = IssueEmail.new
      assert_not issue_email.valid?
      assert_equal [{ error: :blank }], issue_email.errors.details[attr]
    end
  end

  %i[from_email to_email].each do |attr|
    test "validate #{attr} format" do
      val = 'trwes.sdfsdf.de'
      issue_email = IssueEmail.new attr => val
      assert_not issue_email.valid?
      assert_equal [{ error: :email, value: val }], issue_email.errors.details[attr]
    end
  end
end
