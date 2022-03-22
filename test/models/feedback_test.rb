# frozen_string_literal: true

require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  test 'validate author as email' do
    feedback = Feedback.new
    assert_not feedback.valid?
    assert_equal [{ error: :blank }], feedback.errors.details[:author]
    feedback.author = 'abc'
    assert_not feedback.valid?
    assert_equal [{ error: :email, value: 'abc' }], feedback.errors.details[:author]
    feedback.author = 'abc@example.com'
    feedback.valid?
    assert_empty feedback.errors.details[:author]
  end

  test 'authorized scope' do
    Current.user = user(:admin)
    assert_equal Feedback.count, Feedback.authorized.count
    Current.user = user(:regional_admin)
    assert_equal Feedback.where(issue_id: Issue.authorized.select(:id)).count, Feedback.authorized.count
    Current.user = user(:editor)
    assert_empty Feedback.authorized
  end
end
