# frozen_string_literal: true

require 'test_helper'

class EditorialNotificationTest < ActiveSupport::TestCase
  test 'authorized scope' do
    assert_equal EditorialNotification.ids, EditorialNotification.authorized(user(:admin)).ids
    user = user(:regional_admin)
    notifications = EditorialNotification.where(
      user_id: User.authorized(user).map(&:id)
    )
    assert_equal notifications.ids, EditorialNotification.authorized(user).ids
    assert_empty EditorialNotification.authorized(user(:editor)).ids
  end
end
