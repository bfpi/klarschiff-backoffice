# frozen_string_literal: true

require 'test_helper'

class EditorialNotificationTest < ActiveSupport::TestCase
  test 'authorized scope' do
    assert_equal EditorialNotification.ids, EditorialNotification.authorized(user(:admin)).ids
    user = user(:regional_admin)
    notification_ids = EditorialNotification.where(user_id: User.joins(:groups)
      .where(group: { id: Group.authorized(user) })).ids
    assert_not_empty notification_ids
    assert_equal notification_ids.sort, EditorialNotification.authorized(user).ids.sort
    assert_empty EditorialNotification.authorized(user(:editor)).ids
  end
end
