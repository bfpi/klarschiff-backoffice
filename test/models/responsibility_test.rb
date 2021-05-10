# frozen_string_literal: true

require 'test_helper'

class ResponsibilityTest < ActiveSupport::TestCase
  test 'respond_to deleted_at? and deleted' do
    assert_respond_to responsibility(:one), :deleted_at?
    assert_respond_to responsibility(:one), :deleted
  end
end
