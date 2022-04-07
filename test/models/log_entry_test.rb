# frozen_string_literal: true

require 'test_helper'

class LogEntryTest < ActiveSupport::TestCase
  test 'authorized scope' do
    Current.user = user(:admin)
    assert_equal LogEntry.all, LogEntry.authorized
    Current.user = user(:regional_admin)
    assert LogEntry.authorized.any?
    Current.user = user(:editor)
    assert_empty LogEntry.authorized
  end
end
