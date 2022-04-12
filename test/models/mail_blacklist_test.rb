# frozen_string_literal: true

require 'test_helper'

class MailBlacklistTest < ActiveSupport::TestCase
  test 'authorized scope' do
    Current.user = user(:admin)
    assert_equal MailBlacklist.all, MailBlacklist.authorized
    Current.user = user(:regional_admin)
    assert_empty MailBlacklist.authorized
    Current.user = user(:editor)
    assert_empty MailBlacklist.authorized
  end
end
