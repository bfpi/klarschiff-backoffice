# frozen_string_literal: true

require 'test_helper'

class LogEntryTest < ActiveSupport::TestCase
  test 'authorized scope' do
    assert_equal LogEntry.ids, LogEntry.authorized(user(:admin)).ids
    user = user(:regional_admin2)
    assert LogEntry.authorized(user).any?
    assert_not_equal LogEntry.ids, LogEntry.authorized(user).ids
    assert_empty LogEntry.authorized(user(:editor))
  end
end
