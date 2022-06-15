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
    assert_equal Feedback.ids, Feedback.authorized(user(:admin)).ids
    user = user(:regional_admin2)
    assert_equal Issue.authorized(user).flat_map(&:feedback_ids).sort, Feedback.authorized(user).ids.sort
    assert_empty Feedback.authorized(user(:editor)).ids
  end
end
