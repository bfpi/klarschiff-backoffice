# frozen_string_literal: true

require 'test_helper'

class EditorialNotificationTest < ActiveSupport::TestCase
  test 'authorized scope' do
    Current.user = user(:admin)
    assert_equal EditorialNotification.count, EditorialNotification.authorized.count
    Current.user = user(:regional_admin)
    notifications = EditorialNotification.where(
      user_id: User.includes(:groups).where(group: { id: Current.user.group_ids }).select(:id)
    )
    assert_equal notifications.count, EditorialNotification.authorized.count
    Current.user = user(:editor)
    assert_empty EditorialNotification.authorized
  end
end
